import SwiftUI
import CoreLocation

struct DemoNavigationPage: View {
    @State private var startCoord: CLLocationCoordinate2D? = nil
    @State private var destCoord: CLLocationCoordinate2D? = nil
    @State private var isExpanded = true
    @State private var isShowingProfile = false
    @State private var selectedSegment = 0 // 0为总览，1...为分段
    @State private var navigationIndex: Int = 0 // 当前导航段索引，初始为0
    @State private var mapViewId = UUID() // 强制刷新地图
    // mockCoords 与路线顺序一一对应
    let mockCoords: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 23.128, longitude: 113.244),      // 恒宝广场
        CLLocationCoordinate2D(latitude: 23.114778, longitude: 113.237434),// 广州永庆坊
        CLLocationCoordinate2D(latitude: 23.13, longitude: 113.25),        // 陈家祠堂
        CLLocationCoordinate2D(latitude: 23.109819, longitude: 113.242222),// 沙面岛
        CLLocationCoordinate2D(latitude: 23.115, longitude: 113.26),       // 石室圣心大教堂
        CLLocationCoordinate2D(latitude: 23.118, longitude: 113.263)       // 赵记传承
    ]
    let route = RouteDetailView_Previews.mockRoute
    var body: some View {
        print("[DemoNavigationPage] MapView 传参：navigationIndex=\(navigationIndex), startCoordinate=\(mockCoords[navigationIndex])")
        return VStack(spacing: 0) {
            if navigationIndex < mockCoords.count {
                MapView(
                    isExpanded: $isExpanded,
                    isShowingProfile: $isShowingProfile,
                    startCoordinate: mockCoords[navigationIndex],
                    destinationLocation: nil,
                    routeCoordinates: nil
                )
                .frame(height: 350)
            }
            // 路线详情卡片
            RouteDetailView(route: route)
            Button(action: {
                if navigationIndex < mockCoords.count - 1 {
                    navigationIndex += 1
                }
            }) {
                Text("开始/继续导航")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// 给RouteDetailView加一个onStartNavigation回调扩展
extension RouteDetailView {
    func onStartNavigation(_ action: @escaping (CLLocationCoordinate2D, CLLocationCoordinate2D) -> Void) -> some View {
        modifier(StartNavigationModifier(action: action))
    }
}

struct StartNavigationModifier: ViewModifier {
    let action: (CLLocationCoordinate2D, CLLocationCoordinate2D) -> Void
    @State private var lastFrom: CLLocationCoordinate2D? = nil
    @State private var lastTo: CLLocationCoordinate2D? = nil
    func body(content: Content) -> some View {
        content
            .environment(\._startNavigationAction, action)
    }
}

private struct StartNavigationActionKey: EnvironmentKey {
    static let defaultValue: ((CLLocationCoordinate2D, CLLocationCoordinate2D) -> Void)? = nil
}
extension EnvironmentValues {
    var _startNavigationAction: ((CLLocationCoordinate2D, CLLocationCoordinate2D) -> Void)? {
        get { self[StartNavigationActionKey.self] }
        set { self[StartNavigationActionKey.self] = newValue }
    }
} 