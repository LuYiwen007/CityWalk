import SwiftUI
import MapKit

// 地图状态共享对象，负责全局地图摄像头位置同步
class SharedMapState: ObservableObject {
    @Published var cameraPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
}

// 主Tab视图，包含底部导航栏和各主页面
struct MainTabView: View {
    @Binding var selectedTab: Int // 当前选中的Tab索引
    @StateObject private var sharedMapState = SharedMapState() // 地图状态共享对象
    private let tabBarHeight: CGFloat = 48 // 底部Tab栏高度
    
    // 主体视图，渲染Tab内容和底部导航栏
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    // 社区页面（空白）
                    CommunityView()
                        .padding(.bottom, tabBarHeight)
                case 1:
                    // 聊天页面
                    MessageView(sharedMapState: sharedMapState)
                        .padding(.bottom, tabBarHeight)
                case 2:
                    // 我的页面
                    MyPageView()
                        .padding(.bottom, tabBarHeight)
                default:
                    MessageView(sharedMapState: sharedMapState)
                        .padding(.bottom, tabBarHeight)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // 底部Tab栏
            HStack {
                TabBarButton(title: "社区", systemImage: "person.3.fill", selected: selectedTab == 0) {
                    selectedTab = 0
                }
                Spacer()
                TabBarButton(title: "聊天", systemImage: "bubble.left.and.bubble.right.fill", selected: selectedTab == 1) {
                    selectedTab = 1
                }
                Spacer()
                TabBarButton(title: "我的", systemImage: "person.crop.circle", selected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 4)
            .frame(height: tabBarHeight)
            .background(Color(.systemBackground).opacity(0.95).ignoresSafeArea(edges: .bottom))
        }
    }
}

// 底部按钮样式组件
struct TabBarButton: View {
    let title: String
    let systemImage: String
    let selected: Bool
    let action: () -> Void
    // 渲染单个Tab按钮
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(selected ? .blue : .gray)
                Text(title)
                    .font(.system(size: 13, weight: selected ? .bold : .regular))
                    .foregroundColor(selected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// 我的页面占位视图
struct MyPageView: View {
    var body: some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
    }
}

// 新增社区空白页面
struct CommunityView: View {
    var body: some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
    }
} 