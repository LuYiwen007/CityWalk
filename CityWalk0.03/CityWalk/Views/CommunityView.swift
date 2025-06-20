import SwiftUI

struct CommunityView: View {
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<10) { _ in
                    VStack(alignment: .leading, spacing: 8) {
                        // 图片占位
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .padding(24)
                            )
                            .cornerRadius(12)
                        // 标题占位
                        Text("标题占位")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(NSLocalizedString("社区", comment: "社区页面标题"))
    }
} 