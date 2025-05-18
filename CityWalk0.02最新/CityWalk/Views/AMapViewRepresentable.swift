import SwiftUI
import MAMapKit
import AMapSearchKit
import CoreLocation
import AMapLocationKit

struct AMapViewRepresentable: UIViewRepresentable {
    // 可扩展为@Binding参数，支持外部控制
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MAMapView {
        let mapView = MAMapView(frame: .zero)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = context.coordinator
        mapView.zoomLevel = 16
        // 可自定义地图样式
        return mapView
    }
    
    func updateUIView(_ uiView: MAMapView, context: Context) {
        // 可根据需要动态更新地图
    }
    
    class Coordinator: NSObject, MAMapViewDelegate, AMapSearchDelegate {
        var parent: AMapViewRepresentable
        var search: AMapSearchAPI?
        
        init(_ parent: AMapViewRepresentable) {
            self.parent = parent
            super.init()
            self.search = AMapSearchAPI()
            self.search?.delegate = self
        }
        
        // 示例：在地图加载完成后，自动发起一次步行路线规划
        func mapInitComplete(_ mapView: MAMapView!) {
            // 示例起点终点（可替换为实际坐标）
            let origin = CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737) // 上海
            let destination = CLLocationCoordinate2D(latitude: 31.2284, longitude: 121.4787) // 附近
            let request = AMapWalkingRouteSearchRequest()
            request.origin = AMapGeoPoint.location(withLatitude: CGFloat(origin.latitude), longitude: CGFloat(origin.longitude))
            request.destination = AMapGeoPoint.location(withLatitude: CGFloat(destination.latitude), longitude: CGFloat(destination.longitude))
            request.showFieldsType = .all // 确保返回polyline
            search?.aMapWalkingRouteSearch(request)
        }
        
        // 步行路线回调
        func onWalkingRouteSearchDone(_ request: AMapWalkingRouteSearchRequest!, response: AMapRouteSearchResponse!) {
            guard let path = response.route.paths.first, let mapView = search?.delegate as? MAMapView else { return }
            // 解析polyline
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
                (search?.delegate as? MAMapView)?.add(polyline)
            }
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
    }
} 
