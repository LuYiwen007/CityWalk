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
    // ====== 极端方案新增参数 ======
    var navigationIndex: Int? = nil
    var mockCoords: [CLLocationCoordinate2D]? = nil
    // ==========================
    @State private var showRouteSheet: Bool = false
    @State private var mapViewId = UUID()
    
    // 已切换为高德地图，不再需要MapCameraPosition
    var body: some View {
        // 1. 外部传入的 startCoordinate
        print("[MapView] 渲染，外部传入 startCoordinate=\(String(describing: startCoordinate))")
        let currentCoord = startCoordinate
        print("[MapView] body 内 currentCoord=\(String(describing: currentCoord))")
        return GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                AMapViewRepresentable(
                    routeCoordinates: routeCoordinates,
                    startCoordinate: currentCoord,
                    destination: destinationLocation,
                    centerCoordinate: centerCoordinate,
                    navigationIndex: navigationIndex,
                    mockCoords: mockCoords
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
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
