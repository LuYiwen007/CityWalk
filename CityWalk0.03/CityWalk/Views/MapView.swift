import SwiftUI
import CoreLocation
// import MapKit // 注释掉原有MapKit

// 地图视图组件，支持缩放、定位、用户标注等功能
struct MapView: View {
    @Binding var isExpanded: Bool // 控制地图是否展开
    @Binding var isShowingProfile: Bool // 控制是否显示用户资料
    var sharedMapState: SharedMapState? = nil // 可选的地图状态共享对象
    var routeInfo: String?
    let startCoordinate: CLLocationCoordinate2D?
    let destinationLocation: CLLocationCoordinate2D?
    var routeCoordinates: [CLLocationCoordinate2D]? = nil // polyline
    var centerCoordinate: CLLocationCoordinate2D? = nil // 新增地图中心
    @State private var showRouteSheet: Bool = false
    @State private var mapViewId = UUID()
    
    // 已切换为高德地图，不再需要MapCameraPosition
    var body: some View {
        print("[MapView] 渲染，startCoordinate=\(String(describing: startCoordinate))")
        return GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // 用高德地图替换原有MapKit地图
                AMapViewRepresentable(routeCoordinates: routeCoordinates, startCoordinate: startCoordinate, destination: destinationLocation, centerCoordinate: centerCoordinate)
                    .id(mapViewId)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                // 右上角自定义定位按钮和底部分界线等UI保留
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray4))
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .allowsHitTesting(false)
            }
        }
        .sheet(isPresented: $showRouteSheet) {
            if let routeInfo = routeInfo {
                RouteDetailView(route: RouteDetailView_Previews.mockRoute)
                    .presentationDetents([.height(UIScreen.main.bounds.height * 0.6), .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            if routeInfo != nil {
                showRouteSheet = true
            }
        }
        .onChange(of: centerCoordinate?.latitude) { _ in mapViewId = UUID() }
        .onChange(of: centerCoordinate?.longitude) { _ in mapViewId = UUID() }
        .onChange(of: routeCoordinates?.first?.latitude) { _ in mapViewId = UUID() }
        .onChange(of: routeCoordinates?.last?.longitude) { _ in mapViewId = UUID() }
        .onChange(of: routeInfo) { newValue in
            showRouteSheet = newValue != nil
        }
    }
} 
