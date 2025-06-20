import SwiftUI

// 为帖子创建一个数据模型
struct PostItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let authorName: String
    let authorImageName: String
    let likes: Int
}

// 创建一些示例帖子数据
let samplePosts: [PostItem] = [
    PostItem(imageName: "Japan 1", title: "米亚罗霸王山成都出发3.5小时", authorName: "浪迹川西", authorImageName: "SuzhouGarden", likes: 45),
    PostItem(imageName: "Japan 2", title: "成都哪里可以寄存宝宝一个星期", authorName: "沙沙", authorImageName: "SuzhouGarden", likes: 20),
    PostItem(imageName: "Japan", title: "成都融创怎么还不倒闭？", authorName: "匿名用户", authorImageName: "SuzhouGarden", likes: 99),
    PostItem(imageName: "HangzhouWestlake", title: "千岛湖喜来登小红书首发福", authorName: "喜来登", authorImageName: "SuzhouGarden", likes: 108),
    PostItem(imageName: "SuzhouGarden", title: "苏州园林一日游", authorName: "江南梦", authorImageName: "SuzhouGarden", likes: 76),
    PostItem(imageName: "HangzhouWestlake 1", title: "周末西湖边CityWalk", authorName: "杭州小笼包", authorImageName: "SuzhouGarden", likes: 233),
    PostItem(imageName: "Suzhou 1", title: "拙政园的正确打开方式", authorName: "园林艺术", authorImageName: "SuzhouGarden", likes: 12),
    PostItem(imageName: "Japan 1", title: "富士山下的樱花", authorName: "东京爱情故事", authorImageName: "SuzhouGarden", likes: 520),
]

struct CommunityView: View {
    @State private var selectedCategory = 0
    @State private var showMenu = false // 控制侧边栏显示
    let categories = ["推荐", "直播", "短剧", "穿搭", "美食", "旅行"]
    
    // 将帖子分为两列
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                VStack(spacing: 0) {
                    // 自定义导航栏
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.showMenu.toggle()
                            }
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 0) {
                            Text("发现")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.white)
                                .cornerRadius(18)
                            
                            Text("成都")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.clear)
                                .cornerRadius(18)
                        }
                        .background(Color(.systemGray5))
                        .cornerRadius(18)
                        
                        Spacer()

                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .background(Color(.systemGroupedBackground))

                    // 分类滚动视图
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(categories.indices, id: \.self) { index in
                                Button(action: {
                                    selectedCategory = index
                                }) {
                                    Text(categories[index])
                                        .font(selectedCategory == index ? .headline : .subheadline)
                                        .foregroundColor(selectedCategory == index ? .primary : .secondary)
                                        .scaleEffect(selectedCategory == index ? 1.1 : 1.0)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    .background(Color(.systemGroupedBackground))

                    // 帖子瀑布流
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(samplePosts) { post in
                                PostCardView(post: post)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationBarHidden(true)
                .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))

                // 侧边栏菜单 - 更新以匹配TripView
                if showMenu {
                    HStack(spacing: 0) {
                        UserProfileView(isShowingProfile: $showMenu)
                            .frame(width: UIScreen.main.bounds.width * 0.7)
                            .background(Color(.systemBackground))
                            .ignoresSafeArea(edges: .top)
                            .transition(.move(edge: .leading))
                        Spacer(minLength: 0)
                    }
                    .background(
                        Color.black.opacity(0.18)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation { self.showMenu = false }
                            }
                    )
                    .ignoresSafeArea()
                    .zIndex(2)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // 避免iPad上的分栏视图
    }
}

struct PostCardView: View {
    let post: PostItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(post.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: CGFloat.random(in: 150...250)) // 随机高度
                .cornerRadius(12)
                .clipped()
            
            Text(post.title)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            HStack(spacing: 6) {
                Image(post.authorImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                
                Text(post.authorName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "heart")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(post.likes)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
} 