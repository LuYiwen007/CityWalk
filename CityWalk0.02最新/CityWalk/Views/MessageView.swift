import SwiftUI
import MapKit

// 聊天主界面，包含消息列表、输入区和地图弹出逻辑
struct MessageView: View {
    @StateObject private var viewModel = MessageViewModel() // 聊天数据模型
    @StateObject private var settings = SettingsManager.shared // 设置管理器
    @State private var showUserProfile = false // 是否显示用户资料页
    @State private var showSettings = false // 是否显示设置页
    @State private var mapHeight: CGFloat = 0 // 地图高度
    @State private var isChatMinimized = false // 聊天页面是否收缩为小圆圈
    @State private var showChat = true // 是否显示聊天页面
    @State private var showImagePicker = false // 是否显示图片选择器
    @State private var showPhotoActionSheet = false // 是否显示图片操作表
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var dragOffset: CGSize = .zero // 聊天小圆圈拖动偏移
    @Namespace private var animation // 用于动画
    @State private var showProfileDrawer = false // 控制侧边抽屉
    
    // 新增：地图状态共享对象
    var sharedMapState: SharedMapState? = nil
    
    // 地图高度的常量
    private let minMapHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    private let maxMapHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    private let defaultMapHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    
    // 主体视图，渲染聊天界面、消息列表、地图弹窗、输入区等
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 侧边抽屉
            if showProfileDrawer {
                HStack(spacing: 0) {
                    UserProfileView(isShowingProfile: $showProfileDrawer)
                        .frame(width: UIScreen.main.bounds.width * 0.7)
                        .background(Color(.systemBackground))
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
                .zIndex(2)
            }
            // 地图始终在底层
            if !showChat {
                if let sharedMapState = sharedMapState {
                    MapView(isExpanded: .constant(true), isShowingProfile: .constant(false), sharedMapState: sharedMapState)
                        .ignoresSafeArea()
                        .transition(.opacity)
                } else {
                    MapView(isExpanded: .constant(true), isShowingProfile: .constant(false))
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
            // 聊天主页面
            if showChat {
                VStack(spacing: 0) {
                    // 顶部栏
                    HStack {
                        Button(action: {
                            withAnimation { showProfileDrawer = true }
                        }) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        Text("聊天")
                            .font(.system(size: settings.fontSize))
                        Spacer()
                        Button(action: {
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
                    // 聊天消息区
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                        .environment(\.fontSize, settings.fontSize)
                                        .environment(\.language, settings.language)
                                    // 如果是推荐线路消息，展示确认按钮
                                    if message.isRouteRecommendation {
                                        Button(action: {
                                            // 点击确认后收缩聊天页面并显示地图
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                isChatMinimized = true
                                                showChat = false
                                            }
                                        }) {
                                            Text("确认")
                                                .font(.system(size: 15, weight: .bold))
                                                .padding(.horizontal, 18)
                                                .padding(.vertical, 8)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .clipShape(Capsule())
                                                .shadow(radius: 2)
                                        }
                                        .padding(.bottom, 8)
                                    }
                                }
                            }
                            .padding()
                        }
                        .frame(maxHeight: mapHeight > 0 ? UIScreen.main.bounds.height * 0.5 : .infinity)
                        .onChange(of: viewModel.messages.count) { _ in
                            if let lastMessage = viewModel.messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    // "回到地图"按钮
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isChatMinimized = true
                            showChat = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "map")
                            Text("回到地图")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 2)
                    }
                    .padding(.top, 8)
                    // 输入区
                    HStack(spacing: 12) {
                        Button(action: {
                            showPhotoActionSheet = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                        }
                        .actionSheet(isPresented: $showPhotoActionSheet) {
                            ActionSheet(title: Text("选择操作"), buttons: [
                                .default(Text("拍照")) {
                                    imagePickerSource = .camera
                                    showImagePicker = true
                                },
                                .default(Text("从相册选择")) {
                                    imagePickerSource = .photoLibrary
                                    showImagePicker = true
                                },
                                .cancel()
                            ])
                        }
                        TextField(settings.language == "简体中文" ? "发送消息..." : "Send message...", text: $viewModel.inputText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: settings.fontSize))
                            .onSubmit {
                                viewModel.sendMessage()
                            }
                        Button(action: {
                            viewModel.sendMessage()
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .background(Color(.systemBackground))
                    .cornerRadius(0, corners: [.bottomLeft, .bottomRight])
                    .cornerRadius(18, corners: [.topLeft, .topRight])
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray4)),
                        alignment: .bottom
                    )
                    .shadow(radius: 1)
                    .frame(maxWidth: .infinity)
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(sourceType: imagePickerSource) { image in
                            if let image = image, let data = image.jpegData(compressionQuality: 0.8) {
                                let msg = Message(content: "[图片]", isUser: true, timestamp: Date(), imageData: data)
                                viewModel.messages.append(msg)
                                viewModel.sendImageMessage(data: data)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(isChatMinimized ? UIScreen.main.bounds.width / 2 : 0)
                .scaleEffect(isChatMinimized ? 0.14 : 1, anchor: .bottomTrailing)
                .offset(x: isChatMinimized ? UIScreen.main.bounds.width * 0.38 + dragOffset.width : dragOffset.width, y: isChatMinimized ? UIScreen.main.bounds.height * 0.38 + dragOffset.height : dragOffset.height)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isChatMinimized)
                .gesture(
                    isChatMinimized ?
                    DragGesture()
                        .onChanged { value in
                            let minY: CGFloat = 44 // 顶部安全区
                            let maxY: CGFloat = UIScreen.main.bounds.height - 48 - 48 // tab栏高度+圆圈高度
                            let newY = value.translation.height + dragOffset.height
                            if newY >= minY && newY <= maxY {
                                dragOffset = CGSize(width: value.translation.width, height: value.translation.height)
                            }
                        }
                        .onEnded { value in
                            dragOffset = CGSize(width: dragOffset.width + value.translation.width, height: dragOffset.height + value.translation.height)
                        }
                    : nil
                )
                .onTapGesture {
                    if isChatMinimized {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isChatMinimized = false
                            showChat = true
                        }
                    }
                }
            } else if isChatMinimized {
                // 只显示小圆圈
                Circle()
                    .fill(Color.blue)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    )
                    .padding(18)
                    .shadow(radius: 6)
                    .offset(dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let minY: CGFloat = 44
                                let maxY: CGFloat = UIScreen.main.bounds.height - 48 - 44
                                let newY = value.translation.height + dragOffset.height
                                if newY >= minY && newY <= maxY {
                                    dragOffset = CGSize(width: value.translation.width, height: value.translation.height)
                                }
                            }
                            .onEnded { value in
                                dragOffset = CGSize(width: dragOffset.width + value.translation.width, height: dragOffset.height + value.translation.height)
                            }
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isChatMinimized = false
                            showChat = true
                        }
                    }
            }
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
                    if let data = message.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 180, maxHeight: 180)
                            .cornerRadius(12)
                    } else {
                        Text(message.content)
                            .font(.system(size: fontSize))
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    Text(formatTime(message.timestamp))
                        .font(.system(size: fontSize - 4))
                        .foregroundColor(.gray)
                }
            } else {
                VStack(alignment: .leading) {
                    if let data = message.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 180, maxHeight: 180)
                            .cornerRadius(12)
                    } else {
                        Text(message.content)
                            .font(.system(size: fontSize))
                            .padding()
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
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

// 新增图片选择器
import UIKit
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var completion: (UIImage?) -> Void
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            parent.completion(image)
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
            picker.dismiss(animated: true)
        }
    }
} 