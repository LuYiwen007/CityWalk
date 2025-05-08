import SwiftUI
import MapKit

// 地图视图组件，支持缩放、定位、用户标注等功能
struct MapView: View {
    @Binding var isExpanded: Bool // 控制地图是否展开
    @Binding var isShowingProfile: Bool // 控制是否显示用户资料
    var sharedMapState: SharedMapState? = nil // 可选的地图状态共享对象
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic) // 地图摄像头位置
    
    // 主体视图，渲染地图、定位按钮等
    var body: some View {
        GeometryReader { geometry in
            if let sharedMapState {
                // 使用外部共享的地图状态
                Map(position: Binding(
                    get: { sharedMapState.cameraPosition },
                    set: { sharedMapState.cameraPosition = $0 }
                )) {
                    UserAnnotation() // 显示用户当前位置标注
                }
                .mapStyle(.standard)
                .mapControls {
                    // 显示指南针和比例尺
                    MapCompass()
                    MapScaleView()
                }
                // 支持地图缩放手势，动态调整region
                .gesture(
                    MagnificationGesture()
                        .onChanged { scale in
                            if let region = sharedMapState.cameraPosition.region {
                                let factor = 1.0 / scale
                                var newRegion = region
                                newRegion.span.latitudeDelta *= factor
                                newRegion.span.longitudeDelta *= factor
                                sharedMapState.cameraPosition = .region(newRegion)
                            }
                        }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                // 右上角自定义定位按钮，点击后回到用户当前位置
                .overlay(
                    Button(action: {
                        // 设置摄像头位置为用户当前位置
                        sharedMapState.cameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
                    }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.95), Color.blue.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 1.2))
                            .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 2)
                    }
                    .padding([.top, .trailing], 6),
                    alignment: .topTrailing
                )
            } else {
                // 使用本地状态（无外部共享）
                Map(position: $cameraPosition) {
                    UserAnnotation() // 显示用户当前位置标注
                }
                .mapStyle(.standard)
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                // 支持地图缩放手势，动态调整region
                .gesture(
                    MagnificationGesture()
                        .onChanged { scale in
                            if let region = cameraPosition.region {
                                let factor = 1.0 / scale
                                var newRegion = region
                                newRegion.span.latitudeDelta *= factor
                                newRegion.span.longitudeDelta *= factor
                                cameraPosition = .region(newRegion)
                            }
                        }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                // 右上角自定义定位按钮，点击后回到用户当前位置
                .overlay(
                    Button(action: {
                        // 设置摄像头位置为用户当前位置
                        cameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
                    }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.95), Color.blue.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 1.2))
                            .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 2)
                    }
                    .padding([.top, .trailing], 6),
                    alignment: .topTrailing
                )
            }
        }
    }
} 
