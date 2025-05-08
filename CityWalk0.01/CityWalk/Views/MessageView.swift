import SwiftUI
import MapKit

// 聊天主界面，包含消息列表、输入区和地图弹出逻辑
struct MessageView: View {
    @StateObject private var viewModel = MessageViewModel() // 聊天数据模型
    @StateObject private var settings = SettingsManager.shared // 设置管理器
    @State private var showUserProfile = false // 是否显示用户资料页
    @State private var showSettings = false // 是否显示设置页
    @State private var mapHeight: CGFloat = 0 // 地图高度
    
    // 新增：地图状态共享对象
    var sharedMapState: SharedMapState? = nil
    
    // 地图高度的常量
    private let minMapHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    private let maxMapHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    private let defaultMapHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    
    // 主体视图，渲染聊天界面、消息列表、地图弹窗、输入区等
    var body: some View {
        VStack(spacing: 0) {
            // 顶部栏：头像、标题、设置按钮
            HStack {
                Button(action: {
                    // 点击头像，弹出用户资料页
                    showUserProfile = true
                }) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $showUserProfile) {
                    UserProfileView(isShowingProfile: $showUserProfile)
                }
                
                Spacer()
                
                Text("聊天")
                    .font(.system(size: settings.fontSize))
                
                Spacer()
                
                Button(action: {
                    // 点击设置按钮，弹出设置页
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.gray)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(isShowingSettings: $showSettings)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 1)
            
            // 聊天消息区，支持自动滚动到底部
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                                .environment(\.fontSize, settings.fontSize)
                                .environment(\.language, settings.language)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: mapHeight > 0 ? UIScreen.main.bounds.height * 0.5 : .infinity)
                .onChange(of: viewModel.messages.count) { _ in
                    // 新消息时自动滚动到底部
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            // 地图弹窗区域，支持展开/收起
            if mapHeight > 0 {
                if let sharedMapState = sharedMapState {
                    MapView(isExpanded: .constant(true), isShowingProfile: .constant(false), sharedMapState: sharedMapState)
                        .frame(height: mapHeight)
                        .transition(.move(edge: .bottom))
                } else {
                    MapView(isExpanded: .constant(true), isShowingProfile: .constant(false))
                        .frame(height: mapHeight)
                        .transition(.move(edge: .bottom))
                }
            }
            
            // 输入区，包含地图按钮、输入框、发送按钮
            HStack(spacing: 12) {
                Button(action: {
                    // 点击地图按钮，展开/收起地图弹窗
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if mapHeight == 0 {
                            mapHeight = defaultMapHeight
                        } else {
                            mapHeight = 0
                        }
                    }
                }) {
                    Image(systemName: "map")
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                }
                
                TextField(settings.language == "简体中文" ? "发送消息..." : "Send message...", text: $viewModel.inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: settings.fontSize))
                    .onSubmit {
                        // 回车发送消息
                        viewModel.sendMessage()
                    }
                
                Button(action: {
                    // 点击发送按钮，发送消息
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
                .disabled(viewModel.isLoading)
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 1)
        }
        .onAppear {
            // 监听聊天记录清除通知，收到后清空消息
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("ChatHistoryCleared"),
                object: nil,
                queue: .main
            ) { _ in
                viewModel.messages.removeAll()
            }
        }
    }
}

// 聊天气泡视图，负责渲染单条消息内容和时间
struct MessageBubble: View {
    let message: Message
    @Environment(\.fontSize) var fontSize
    @Environment(\.language) var language
    
    // 格式化时间显示，支持今天、昨天、周几、日期等多种格式
    private func formatTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
        let nowComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let timeString = timeFormatter.string(from: date)
        
        // 如果是今天
        if calendar.isDateInToday(date) {
            return timeString
        }
        
        // 如果是昨天
        if calendar.isDateInYesterday(date) {
            return (language == "简体中文" ? "昨天 " : "Yesterday ") + timeString
        }
        
        // 计算日期差
        let dayDiff = calendar.dateComponents([.day], from: date, to: now).day ?? 0
        
        // 如果在一周内
        if dayDiff < 7 {
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.locale = Locale(identifier: language == "简体中文" ? "zh_CN" : "en_US")
            weekdayFormatter.dateFormat = "EEEE"
            return weekdayFormatter.string(from: date) + " " + timeString
        }
        
        // 其他情况显示年月
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: language == "简体中文" ? "zh_CN" : "en_US")
        
        // 如果是今年
        if components.year == nowComponents.year {
            dateFormatter.dateFormat = language == "简体中文" ? "M月d日" : "MMM d"
        } else {
            dateFormatter.dateFormat = language == "简体中文" ? "yyyy年M月d日" : "MMM d, yyyy"
        }
        
        return dateFormatter.string(from: date) + " " + timeString
    }
    
    // 渲染单条消息气泡及时间
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.content)
                        .font(.system(size: fontSize))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Text(formatTime(message.timestamp))
                        .font(.system(size: fontSize - 4))
                        .foregroundColor(.gray)
                }
            } else {
                VStack(alignment: .leading) {
                    Text(message.content)
                        .font(.system(size: fontSize))
                        .padding()
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Text(formatTime(message.timestamp))
                        .font(.system(size: fontSize - 4))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
    }
}

// 自定义圆角扩展，支持指定圆角方向
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// 圆角Shape，配合cornerRadius扩展使用
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                               byRoundingCorners: corners,
                               cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
} 