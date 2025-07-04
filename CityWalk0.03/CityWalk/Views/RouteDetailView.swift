import SwiftUI
import Foundation
import CoreLocation

struct RouteDetailView: View {
    let route: Route
    
    @State private var selectedTab = 0 // 0 表示总览，1...表示各个地点
    @State private var places: [Place]
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss
    // 新增导航相关状态
    @State private var navigationIndex: Int? = nil // 当前导航段索引
    @State private var userLocation: CLLocationCoordinate2D? = nil // 用户当前位置
    @State private var destinationLocation: CLLocationCoordinate2D? = nil // 当前目标地经纬度
    @State private var isNavigating: Bool = false // 是否正在导航
    @State private var isLoadingPOI: Bool = false // 是否正在请求POI
    @State private var locationManager = CLLocationManager()
    @State private var locationManagerDelegate = LocationDelegate()
    @State private var startCoordinate: CLLocationCoordinate2D? = nil // 当前分段起点
    
    init(route: Route) {
        self.route = route
        _places = State(initialValue: route.places)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                // 标题
                HStack {
                    Text(route.title)
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                    HStack(spacing: -10) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // 总览和地点tabs
                        VStack(alignment: .leading, spacing: 8) {
                            // Tab栏
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    // 总览tab
                                    Button(action: {
                                        selectedTab = 0
                                    }) {
                                        VStack(spacing: 4) {
                                            Text("总览")
                                                .font(.headline)
                                                .foregroundColor(selectedTab == 0 ? .blue : .primary)
                                            Rectangle()
                                                .frame(width: 30, height: 4)
                                                .foregroundColor(selectedTab == 0 ? .blue : .clear)
                                                .cornerRadius(2)
                                        }
                                    }
                                    
                                    // 各个地点tabs
                                    ForEach(Array(places.enumerated()), id: \ .offset) { index, place in
                                        Button(action: {
                                            selectedTab = index + 1
                                        }) {
                                            VStack(spacing: 4) {
                                                Text(place.name)
                                                    .font(.caption)
                                                    .foregroundColor(selectedTab == index + 1 ? .blue : .primary)
                                                    .lineLimit(1)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                Rectangle()
                                                    .frame(width: 30, height: 4)
                                                    .foregroundColor(selectedTab == index + 1 ? .blue : .clear)
                                                    .cornerRadius(2)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal)

                        // 根据选中的tab显示不同内容
                        if selectedTab == 0 {
                            // 总览内容
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "map.fill")
                                        .foregroundColor(.blue)
                                    Text("行程概览")
                                        .font(.headline)
                                }
                                .padding(.bottom, 8)
                                
                                // 地点列表
                                VStack(spacing: 12) {
                                    ForEach(Array(places.enumerated()), id: \ .offset) { index, place in
                                        HStack(spacing: 12) {
                                            // 序号圆圈
                                            ZStack {
                                                Circle()
                                                    .fill(Color.blue)
                                                    .frame(width: 30, height: 30)
                                                Text("\(index + 1)")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                            }
                                            // 地点信息
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(place.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.primary)
                                                Text("第\(index + 1)站")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            if isEditing {
                                                // 负号按钮
                                                Button(action: {
                                                    places.remove(at: index)
                                                    // 如果当前tab被删，跳回总览tab
                                                    if selectedTab == index + 1 {
                                                        selectedTab = 0
                                                    } else if selectedTab > places.count {
                                                        selectedTab = 0
                                                    }
                                                }) {
                                                    Image(systemName: "minus.circle.fill")
                                                        .foregroundColor(.red)
                                                        .font(.title3)
                                                }
                                            }
                                            // 箭头图标（除了最后一个地点）
                                            if index < places.count - 1 {
                                                Image(systemName: "arrow.down")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        } else if selectedTab > 0, selectedTab <= places.count {
                            // 具体地点内容
                            let placeIndex = selectedTab - 1
                            let place = places[placeIndex]
                            
                            VStack(alignment: .leading, spacing: 16) {
                                // 地点图片
                                if let imageName = place.imageName, !imageName.isEmpty, UIImage(named: imageName) != nil {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 200)
                                        .clipped()
                                        .cornerRadius(12)
                                } else {
                                    Image(systemName: "photo")
                                        .font(.system(size: 200))
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 200)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .overlay(
                                            Text("\(place.name) 图片")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        )
                                }
                                // 地点介绍文字
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(place.name)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Text(place.detail)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .lineSpacing(4)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            // 底部按钮区
            HStack(spacing: 12) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemGray5))
                .clipShape(Circle())
                
                Button(action: {
                    selectedTab = 0 // 跳回总览tab
                    isEditing.toggle()
                }) {
                    HStack {
                        Image(systemName: isEditing ? "xmark.circle" : "square.and.pencil")
                        Text(isEditing ? "停止编辑" : "编辑路线")
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(25)
                // 新增"开始导航"按钮
                Button(action: {
                    if navigationIndex == nil {
                        // 开始第一段导航
                        navigationIndex = 0
                        startNavigation()
                    } else if let idx = navigationIndex, idx < places.count - 1 {
                        // 继续下一段导航
                        navigationIndex = idx + 1
                        startNavigation()
                    }
                }) {
                    HStack {
                        Image(systemName: isNavigating ? "location.north.line" : "location")
                        Text(navigationIndex == nil ? "开始导航" : (navigationIndex! < places.count - 1 ? "继续导航" : "已完成"))
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(navigationIndex == nil || (navigationIndex! < places.count - 1) ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(25)
                .disabled(isLoadingPOI || (navigationIndex != nil && navigationIndex! >= places.count - 1))
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
            .padding(.horizontal)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }
    // 导航逻辑：用POI名称查经纬度并发起导航
    func startNavigation() {
        guard let idx = navigationIndex, idx < places.count - 1 else { print("[导航] navigationIndex无效"); return }
        isLoadingPOI = true
        let fromName: String
        if idx == 0 {
            fromName = places[0].name
        } else {
            fromName = places[idx].name
        }
        let toName = places[idx + 1].name
        print("[导航] startNavigation from=\(fromName) to=\(toName)")
        AMapPOISearchHelper.searchPOI(keyword: fromName) { fromCoord in
            print("[导航] 起点POI查找结果 from=\(fromName), coord=\(String(describing: fromCoord))")
            guard let fromCoord = fromCoord else { isLoadingPOI = false; print("[导航] 起点查找失败"); return }
            AMapPOISearchHelper.searchPOI(keyword: toName) { poiCoord in
                print("[导航] 终点POI查找结果 to=\(toName), coord=\(String(describing: poiCoord))")
                isLoadingPOI = false
                if let destCoord = poiCoord {
                    // 强制刷新地图组件
                    startCoordinate = nil
                    destinationLocation = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        startCoordinate = fromCoord
                        destinationLocation = destCoord
                        print("[导航] 设置startCoordinate=\(fromCoord), destinationLocation=\(destCoord)")
                        isNavigating = true
                    }
                } else {
                    print("[导航] 终点查找失败")
                }
            }
        }
    }
}

// 辅助：定位代理
class LocationDelegate: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D? = nil
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            currentLocation = loc.coordinate
        }
    }
}

// 辅助：高德POI搜索
class AMapPOISearchHelper {
    static func searchPOI(keyword: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let apiKey = "d87559570133cb52b49cf4b0aa772ff0"
        let city = "广州"
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://restapi.amap.com/v3/place/text?key=\(apiKey)&keywords=\(encodedKeyword)&city=\(city)&output=JSON&offset=1&page=1"
        print("[POI搜索] keyword=\(keyword), url=\(urlString)")
        guard let url = URL(string: urlString) else {
            print("[POI搜索] URL无效")
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("[POI搜索] 网络错误：", error)
                completion(nil)
                return
            }
            guard let data = data else {
                print("[POI搜索] 无数据")
                completion(nil)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let pois = json["pois"] as? [[String: Any]],
                   let first = pois.first,
                   let location = first["location"] as? String {
                    let comps = location.split(separator: ",")
                    if comps.count == 2, let lon = Double(comps[0]), let lat = Double(comps[1]) {
                        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        print("[POI搜索] 结果 keyword=\(keyword), coord=\(coord)")
                        completion(coord)
                        return
                    }
                }
                print("[POI搜索] 未找到POI或经纬度解析失败 keyword=\(keyword)")
                completion(nil)
            } catch {
                print("[POI搜索] 解析错误：", error)
                completion(nil)
            }
        }
        task.resume()
    }
}

// 预览和mock数据
struct RouteDetailView_Previews: PreviewProvider {
    static let mockRoute = Route(
        title: "越秀公园1小时徒步路线",
        author: "小明",
        description: "广州是一座充满历史韵味和美食的城市。本次行程将带你领略老广的市井生活，品尝地道美食。",
        places: [
            Place(name: "恒宝广场", detail: "广州著名商圈，购物美食聚集地。", imageName: nil),
            Place(name: "广州永庆坊", detail: "历史文化街区，感受老广州风情。", imageName: nil),
            Place(name: "陈家祠堂", detail: "岭南建筑代表，精美砖雕。", imageName: nil),
            Place(name: "沙面岛", detail: "欧式建筑群，拍照圣地。", imageName: nil),
            Place(name: "广州石室耶稣圣心大教堂", detail: "哥特式天主教堂，地标建筑。", imageName: nil),
            Place(name: "赵记传承(一德路店)", detail: "地道小吃，老字号。", imageName: nil)
        ]
    )
    static var previews: some View {
        RouteDetailView(route: mockRoute)
    }
} 
