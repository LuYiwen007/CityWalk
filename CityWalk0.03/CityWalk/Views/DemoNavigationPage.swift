import SwiftUI
import CoreLocation

struct DemoNavigationPage: View {
    @State private var startCoord: CLLocationCoordinate2D? = nil
    @State private var destCoord: CLLocationCoordinate2D? = nil
    @State private var isExpanded = true
    @State private var isShowingProfile = false

    // 这里用mockRoute，实际可替换为你的Route数据
    let route = RouteDetailView_Previews.mockRoute

    var body: some View {
        VStack(spacing: 0) {
            // 地图
            MapView(
                isExpanded: $isExpanded,
                isShowingProfile: $isShowingProfile,
                startCoordinate: $startCoord,
                destinationLocation: $destCoord
            )
            .frame(height: 350)
            // 路线详情卡片
            RouteDetailView(route: route)
                .onStartNavigation { from, to in
                    // 强制刷新逻辑
                    startCoord = nil
                    destCoord = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        startCoord = from
                        destCoord = to
                    }
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