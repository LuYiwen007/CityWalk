import SwiftUI
import MAMapKit
import AMapSearchKit
import CoreLocation
import AMapLocationKit

struct AMapViewRepresentable: UIViewRepresentable {
    // 支持外部传入路线点串
    var routeCoordinates: [CLLocationCoordinate2D]?
    // 新增：可选的目的地坐标（用于手动导航）
    @Binding var destination: CLLocationCoordinate2D?
    // 新增：搜索回调
    var onSearch: ((String) -> Void)? = nil
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: .zero)
        let mapView = MAMapView(frame: .zero)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = context.coordinator
        mapView.zoomLevel = 16
        mapView.isShowTraffic = false
        mapView.isRotateEnabled = false
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        AMapServices.shared().enableHTTPS = true
        context.coordinator.mapView = mapView
        // 主动请求系统定位权限
        let clManager = CLLocationManager()
        clManager.requestWhenInUseAuthorization()
        // 默认定位到用户当前位置
        let locationManager = AMapLocationManager()
        locationManager.delegate = context.coordinator // 新增：设置delegate
        locationManager.requestLocation(withReGeocode: false) { location, _, _ in
            if let loc = location {
                mapView.setCenter(loc.coordinate, animated: false)
            }
        }
        mapView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: container.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        // 自定义美化搜索框
        let searchView = CustomSearchBarView()
        searchView.delegate = context.coordinator
        searchView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(searchView)
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: 12),
            searchView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            searchView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            searchView.heightAnchor.constraint(equalToConstant: 52)
        ])
        // 右下角定位按钮
        let locateBtn = UIButton(type: .custom)
        locateBtn.setImage(UIImage(systemName: "location.fill"), for: .normal)
        locateBtn.backgroundColor = .white
        locateBtn.layer.cornerRadius = 24
        locateBtn.layer.shadowColor = UIColor.black.cgColor
        locateBtn.layer.shadowOpacity = 0.12
        locateBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        locateBtn.layer.shadowRadius = 6
        locateBtn.translatesAutoresizingMaskIntoConstraints = false
        locateBtn.addTarget(context.coordinator, action: #selector(Coordinator.locateUser), for: .touchUpInside)
        container.addSubview(locateBtn)
        NSLayoutConstraint.activate([
            locateBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            locateBtn.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -90),
            locateBtn.widthAnchor.constraint(equalToConstant: 48),
            locateBtn.heightAnchor.constraint(equalToConstant: 48)
        ])
        // 信息卡片（初始隐藏）
        let infoCard = context.coordinator.infoCardView
        infoCard.isHidden = true
        infoCard.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(infoCard)
        NSLayoutConstraint.activate([
            infoCard.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            infoCard.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            infoCard.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -32),
            infoCard.heightAnchor.constraint(equalToConstant: 110)
        ])
        // 优化指南针位置
        mapView.compassOrigin = CGPoint(x: container.bounds.width - 60, y: 80)
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let mapView = context.coordinator.mapView else { return }
        mapView.removeOverlays(mapView.overlays)
        if let coordinates = routeCoordinates, !coordinates.isEmpty {
            var coords = coordinates
            let polyline = MAPolyline(coordinates: &coords, count: UInt(coords.count))
            mapView.add(polyline)
        } else if let dest = destination {
            if let userLoc = mapView.userLocation.location?.coordinate {
                context.coordinator.searchWalkingRoute(from: userLoc, to: dest, on: mapView)
            }
        }
    }

    class Coordinator: NSObject, MAMapViewDelegate, AMapSearchDelegate, CustomSearchBarViewDelegate, AMapLocationManagerDelegate {
        var parent: AMapViewRepresentable
        var search: AMapSearchAPI?
        var mapView: MAMapView?
        var currentPOI: AMapPOI?
        let infoCardView = InfoCardView()
        var currentMapView: MAMapView? = nil
        var currentDest: CLLocationCoordinate2D? = nil
        var currentAnnotation: MAPointAnnotation? = nil
        // 新增：缓存用户最新位置
        var latestUserLocation: CLLocationCoordinate2D?
        
        init(_ parent: AMapViewRepresentable) {
            self.parent = parent
            super.init()
            self.search = AMapSearchAPI()
            self.search?.delegate = self
            infoCardView.isHidden = true
            infoCardView.onRoute = { [weak self] in
                guard let self = self, let mapView = self.mapView, let dest = self.currentDest else { return }
                // 优先使用缓存的用户位置
                if let userLoc = self.latestUserLocation ?? mapView.userLocation.location?.coordinate {
                    print("点击导航按钮，准备发起步行路线规划：\(userLoc) -> \(dest)")
                    self.searchWalkingRoute(from: userLoc, to: dest, on: mapView)
                } else {
                    print("点击导航按钮，但未获取到用户当前位置（userLocation为nil）")
                }
                self.infoCardView.isHidden = true
            }
        }
        // 定位按钮点击
        @objc func locateUser() {
            guard let mapView = mapView else { return }
            if let userLoc = mapView.userLocation.location?.coordinate {
                mapView.setCenter(userLoc, animated: true)
            }
        }
        // 搜索目的地
        func didTapSearch(with keyword: String) {
            guard !keyword.isEmpty else { return }
            let request = AMapPOIKeywordsSearchRequest()
            request.keywords = keyword
            request.city = nil
            search?.aMapPOIKeywordsSearch(request)
        }
        // POI搜索回调
        func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
            guard let poi = response.pois.first, let mapView = mapView else { return }
            let dest = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location.latitude), longitude: CLLocationDegrees(poi.location.longitude))
            mapView.setCenter(dest, animated: true)
            // 弹出信息卡片
            infoCardView.configure(title: poi.name, address: poi.address)
            infoCardView.isHidden = false
            currentDest = dest
        }
        // 步行路线规划
        func searchWalkingRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, on mapView: MAMapView) {
            print("开始步行路线规划：\(origin) -> \(destination)")
            let request = AMapWalkingRouteSearchRequest()
            request.origin = AMapGeoPoint.location(withLatitude: CGFloat(origin.latitude), longitude: CGFloat(origin.longitude))
            request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destination.latitude), longitude: CGFloat(destination.longitude))
            request.showFieldsType = .all
            search?.aMapWalkingRouteSearch(request)
            self.currentMapView = mapView
        }
        // 步行路线回调
        func onWalkingRouteSearchDone(_ request: AMapWalkingRouteSearchRequest!, response: AMapRouteSearchResponse!) {
            print("步行路线回调 onWalkingRouteSearchDone 被调用")
            guard let path = response.route.paths.first, let mapView = currentMapView else { 
                print("步行路线回调但无有效路径或mapView为nil")
                return 
            }
            if let steps = path.steps as? [AMapStep] {
                var coordinates: [CLLocationCoordinate2D] = []
                for step in steps {
                    let polylineStr = step.polyline
                    let points = polylineStr?.split(separator: ";").compactMap { pair -> CLLocationCoordinate2D? in
                        let comps = pair.split(separator: ",")
                        if comps.count == 2, let lon = Double(comps[0]), let lat = Double(comps[1]) {
                            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        }
                        return nil
                    } ?? []
                    coordinates.append(contentsOf: points)
                }
                let polyline = MAPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
                mapView.removeOverlays(mapView.overlays)
                mapView.add(polyline)
                print("步行路线已绘制，点数：\(coordinates.count)")
            } else {
                print("步行路线回调但steps为空")
            }
        }
        // 捕获高德SDK请求失败
        func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
            print("高德步行路线请求失败：\(error.localizedDescription)")
        }
        // 绘制路线
        func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
            if let polyline = overlay as? MAPolyline {
                let renderer = MAPolylineRenderer(polyline: polyline)
                renderer?.strokeColor = UIColor.systemBlue
                renderer?.lineWidth = 5
                return renderer
            }
            return nil
        }
        // 新增：监听用户位置更新
        func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
            if updatingLocation, let coord = userLocation.location?.coordinate {
                latestUserLocation = coord
            }
        }
        // MARK: - MAMapViewDelegate
        func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
            locationManager.requestWhenInUseAuthorization()
        }

        // MARK: - AMapLocationManagerDelegate
        func amapLocationManager(_ manager: AMapLocationManager!, doRequireLocationAuth locationManager: CLLocationManager!) {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

// 自定义美化搜索框
protocol CustomSearchBarViewDelegate: AnyObject {
    func didTapSearch(with keyword: String)
}
class CustomSearchBarView: UIView, UITextFieldDelegate {
    weak var delegate: CustomSearchBarViewDelegate?
    private let iconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
    private let textField = UITextField()
    private let micView = UIImageView(image: UIImage(systemName: "mic.fill"))
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.95)
        layer.cornerRadius = 26
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        iconView.tintColor = .gray
        micView.tintColor = .gray
        textField.placeholder = "搜索地点/POI"
        textField.font = UIFont.boldSystemFont(ofSize: 18)
        textField.textColor = .darkGray
        textField.delegate = self
        textField.returnKeyType = .search
        let stack = UIStackView(arrangedSubviews: [iconView, textField, micView])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            micView.widthAnchor.constraint(equalToConstant: 28),
            micView.heightAnchor.constraint(equalToConstant: 28),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            delegate?.didTapSearch(with: text)
        }
        textField.resignFirstResponder()
        return true
    }
}

// 信息卡片视图
class InfoCardView: UIView {
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let routeButton = UIButton(type: .system)
    var onRoute: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = .darkGray
        addressLabel.numberOfLines = 2
        routeButton.setTitle("路线/导航", for: .normal)
        routeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        routeButton.backgroundColor = UIColor.systemBlue
        routeButton.setTitleColor(.white, for: .normal)
        routeButton.layer.cornerRadius = 8
        routeButton.addTarget(self, action: #selector(routeTapped), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel, routeButton])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .leading
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            routeButton.heightAnchor.constraint(equalToConstant: 40),
            routeButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(title: String, address: String) {
        titleLabel.text = title
        addressLabel.text = address
    }
    @objc private func routeTapped() {
        onRoute?()
    }
} 
 