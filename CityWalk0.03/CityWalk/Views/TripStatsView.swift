import SwiftUI
import CoreLocation

struct TripStatsView: View {
    // 轨迹坐标
    var routeCoordinates: [CLLocationCoordinate2D] = []
    // 统计数据
    var duration: TimeInterval = 3600 // 秒
    var distance: Double = 5.2 // 公里
    var calories: Double = 320 // 千卡
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 上部地图
                AMapViewRepresentable(routeCoordinates: routeCoordinates, destination: .constant(nil), showSearchBar: false)
                    .frame(height: geometry.size.height * 0.45)
                    .clipped()
                // 下部统计信息
                VStack(spacing: 24) {
                    Text("旅程统计")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 24)
                    HStack(spacing: 32) {
                        VStack {
                            Text("用时")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(timeString)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        VStack {
                            Text("路程")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f km", distance))
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        VStack {
                            Text("卡路里")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.0f kcal", calories))
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
            }
            .edgesIgnoringSafeArea(.top)
            .overlay(
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                .padding(.leading, 16)
                .padding(.top, 40)
                , alignment: .topLeading
            )
        }
    }
    // 用时格式化
    var timeString: String {
        let h = Int(duration) / 3600
        let m = (Int(duration) % 3600) / 60
        let s = Int(duration) % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
}

// 预览
struct TripStatsView_Previews: PreviewProvider {
    static var previews: some View {
        TripStatsView()
    }
} 