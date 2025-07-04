import SwiftUI
import CoreLocation

struct PostDetailView: View {
    let post: CommunityPostItem
    // 可选：路线坐标
    var routeCoordinates: [CLLocationCoordinate2D] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                Spacer()
                Text(post.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Spacer().frame(width: 36)
            }
            .padding(.horizontal)
            .padding(.top, 24)
            .padding(.bottom, 12)
            .background(Color.white)
            
            // 中部照片封面
            Image(post.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 220)
                .clipped()
                .cornerRadius(16)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            
            // 底部地图
            AMapViewRepresentable(routeCoordinates: routeCoordinates, startCoordinate: nil, destination: nil, showSearchBar: false)
                .frame(maxHeight: .infinity)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// 预览
struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(post: samplePosts[0])
    }
} 