import SwiftUI
// import MapKit // 注释掉原有MapKit

// 地图视图组件，支持缩放、定位、用户标注等功能
struct MapView: View {
    @Binding var isExpanded: Bool // 控制地图是否展开
    @Binding var isShowingProfile: Bool // 控制是否显示用户资料
    var sharedMapState: SharedMapState? = nil // 可选的地图状态共享对象
    
    // 已切换为高德地图，不再需要MapCameraPosition
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // 用高德地图替换原有MapKit地图
                AMapViewRepresentable()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                // 右上角自定义定位按钮和底部分界线等UI保留
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray4))
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .allowsHitTesting(false)
            }
        }
    }
} 
