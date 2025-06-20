import SwiftUI

struct Trip: Identifiable {
    let id = UUID()
    let title: String
    let days: String
    let locations: String
    let image: Image?
    let avatar: Image?
    let date: Date
}

struct TripView: View {
    // 示例数据
    @State private var currentTrip = Trip(title: "日本历史8天行程", days: "8天7晚", locations: "30个地点", image: Image("Japan"), avatar: Image("avatar_sample"), date: Date())
    @State private var historyTrips: [Trip] = [
        Trip(title: "苏州园林3日游", days: "3天2晚", locations: "9个地点", image: Image("SuzhouGarden"), avatar: nil, date: Date().addingTimeInterval(-86400*10)),
        Trip(title: "杭州西湖2日游", days: "2天1晚", locations: "8个地点", image: Image("HangzhouWestlake"), avatar: nil, date: Date().addingTimeInterval(-86400*20))
    ]
    
    // 新增状态变量
    @State private var showUserProfile = false // 是否显示用户资料页
    @State private var showSettings = false // 是否显示设置页
    @State private var showProfileDrawer = false // 控制侧边抽屉
    @StateObject private var settings = SettingsManager.shared // 设置管理器
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.98, green: 0.99, blue: 1.0),
                    Color.white
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 侧边抽屉
            if showProfileDrawer {
                HStack(spacing: 0) {
                    UserProfileView(isShowingProfile: $showProfileDrawer)
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
                            withAnimation { showProfileDrawer = false }
                        }
                )
                .ignoresSafeArea()
                .zIndex(2)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 顶部栏
                    HStack {
                        Button(action: {
                            withAnimation { showProfileDrawer = true }
                        }) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        Spacer()
                        Text("我的")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .sheet(isPresented: $showSettings) {
                            SettingsView(isShowingSettings: $showSettings)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.8))
                    .blur(radius: 0.5)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // 欢迎区域
                        VStack(alignment: .leading, spacing: 8) {
                            Text("欢迎回来")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            Text("继续您的精彩旅程")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // 当前行程
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("当前行程")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("进行中")
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 20)
                            
                            TripCardView(trip: currentTrip, isCurrent: true)
                                .padding(.horizontal, 20)
                        }
                        
                        // 历史行程
                        VStack(alignment: .leading, spacing: 16) {
                            Text("历史行程")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 16) {
                                ForEach(historyTrips.sorted(by: { $0.date > $1.date })) { trip in
                                    TripCardView(trip: trip, isCurrent: false)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // 底部间距
                        Spacer(minLength: 100)
                    }
                }
            }
        }
    }
}

struct TripCardView: View {
    let trip: Trip
    let isCurrent: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 主卡片背景
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: isCurrent ? 
                            [Color(red: 0.2, green: 0.6, blue: 1.0), Color(red: 0.1, green: 0.4, blue: 0.9)] :
                            [Color.white, Color(red: 0.98, green: 0.98, blue: 0.98)]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: isCurrent ? Color.blue.opacity(0.3) : Color.black.opacity(0.08), 
                       radius: isCurrent ? 12 : 8, x: 0, y: isCurrent ? 6 : 4)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(trip.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(isCurrent ? .white : .primary)
                            .lineLimit(2)
                        
                        HStack(spacing: 20) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14))
                                    .foregroundColor(isCurrent ? .white.opacity(0.8) : .gray)
                                Text(trip.days)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(isCurrent ? .white.opacity(0.9) : .gray)
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 14))
                                    .foregroundColor(isCurrent ? .white.opacity(0.8) : .gray)
                                Text(trip.locations)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(isCurrent ? .white.opacity(0.9) : .gray)
                            }
                        }
                    }
                    Spacer()
                    
                    // 右上图片区域
                    if let img = trip.image {
                        img
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .onAppear {
                                // 如果图片加载失败，会显示占位符
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 100)
                            .overlay(
                                VStack(spacing: 4) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("暂无图片")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                            )
                    }
                }
                
                Spacer(minLength: 0)
                
                // 底部操作区域
                HStack(spacing: 12) {
                    // 头像区域
                    if let avatar = trip.avatar {
                        avatar
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    // 添加按钮
                    Button(action: {
                        // TODO: 添加行程操作
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                            Text("添加")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(isCurrent ? .white : .blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isCurrent ? Color.white.opacity(0.2) : Color.blue.opacity(0.1))
                        )
                    }
                    
                    Spacer()
                    
                    // 状态指示器
                    if isCurrent {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 6, height: 6)
                            Text("进行中")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
            }
            .padding(20)
        }
        .frame(height: 200)
    }
} 