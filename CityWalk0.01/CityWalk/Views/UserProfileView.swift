import SwiftUI

// 用户视图模型，管理登录状态、用户名、头像等
class UserViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var username: String = "游客用户"
    @Published var userAvatar: Image = Image(systemName: "person.circle.fill")
    
    // 登录方法，模拟登录逻辑
    func login(username: String, password: String) -> Bool {
        // TODO: 实现实际的登录逻辑
        self.username = username
        self.isLoggedIn = true
        return true
    }
    
    // 登出方法，重置用户信息
    func logout() {
        self.username = "游客用户"
        self.isLoggedIn = false
        self.userAvatar = Image(systemName: "person.circle.fill")
    }
    
    // 更新头像方法
    func updateAvatar(_ image: Image) {
        self.userAvatar = image
    }
}

// 用户资料页，支持登录、登出、修改头像、查看历史等
struct UserProfileView: View {
    @Binding var isShowingProfile: Bool // 控制资料页显示/隐藏
    @StateObject private var userViewModel = UserViewModel()
    @State private var showingLoginSheet = false
    @State private var showingRegisterSheet = false
    @State private var showingLogoutAlert = false
    @State private var showingImagePicker = false
    
    // 主体视图，渲染用户信息、功能区、弹窗等
    var body: some View {
        NavigationView {
            List {
                // 用户信息区域
                Section {
                    HStack {
                        Button(action: {
                            // 已登录时可修改头像
                            if userViewModel.isLoggedIn {
                                showingImagePicker = true
                            }
                        }) {
                            userViewModel.userAvatar
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                                .clipShape(Circle())
                        }
                        .disabled(!userViewModel.isLoggedIn)
                        
                        Button(action: {
                            // 已登录时可登出，未登录时弹出登录页
                            if userViewModel.isLoggedIn {
                                showingLogoutAlert = true
                            } else {
                                showingLoginSheet = true
                            }
                        }) {
                            VStack(alignment: .leading) {
                                Text(userViewModel.username)
                                    .font(.headline)
                                Text(userViewModel.isLoggedIn ? "点击退出登录" : "点击登录")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.leading)
                    }
                    .padding(.vertical)
                }
                
                // 功能区域
                Section("功能") {
                    NavigationLink(destination: HistoryView()) {
                        Label("历史记录", systemImage: "clock")
                    }
                }
            }
            .navigationTitle("个人中心")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        // 关闭资料页
                        isShowingProfile = false
                    }
                }
            }
            .sheet(isPresented: $showingLoginSheet) {
                // 登录弹窗
                LoginView(userViewModel: userViewModel, isPresented: $showingLoginSheet, showRegister: $showingRegisterSheet)
            }
            .sheet(isPresented: $showingRegisterSheet) {
                // 注册弹窗
                RegisterView(isPresented: $showingRegisterSheet)
            }
            .alert("退出登录", isPresented: $showingLogoutAlert) {
                Button("取消", role: .cancel) { }
                Button("确认退出", role: .destructive) {
                    userViewModel.logout()
                }
            } message: {
                Text("确定要退出登录吗？")
            }
            .sheet(isPresented: $showingImagePicker) {
                // TODO: 实现图片选择器
                Text("选择头像")
            }
        }
    }
}

// 登录弹窗视图
struct LoginView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Binding var isPresented: Bool
    @Binding var showRegister: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    
    // 主体视图，渲染登录表单
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("用户名", text: $username)
                    SecureField("密码", text: $password)
                }
                
                Section {
                    Button("登录") {
                        // 登录逻辑，成功则关闭弹窗
                        if userViewModel.login(username: username, password: password) {
                            isPresented = false
                        } else {
                            showingAlert = true
                        }
                    }
                    .disabled(username.isEmpty || password.isEmpty)
                    
                    Button("还没有账号？立即注册") {
                        // 跳转到注册弹窗
                        isPresented = false
                        showRegister = true
                    }
                }
            }
            .navigationTitle("登录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
            .alert("登录失败", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("用户名或密码错误")
            }
        }
    }
}

// 注册弹窗视图
struct RegisterView: View {
    @Binding var isPresented: Bool
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 主体视图，渲染注册表单
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("用户名", text: $username)
                    SecureField("密码", text: $password)
                    SecureField("确认密码", text: $confirmPassword)
                }
                
                Section {
                    Button("注册") {
                        // TODO: 实现注册逻辑
                        if password != confirmPassword {
                            alertMessage = "两次输入的密码不一致"
                            showingAlert = true
                            return
                        }
                        // 处理注册成功的情况
                        isPresented = false
                    }
                    .disabled(username.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                }
            }
            .navigationTitle("注册")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
            .alert("注册失败", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

// 历史记录视图
struct HistoryView: View {
    // 主体视图，渲染历史记录列表
    var body: some View {
        List {
            ForEach(0..<10) { i in
                VStack(alignment: .leading) {
                    Text("历史记录 \(i + 1)")
                        .font(.headline)
                    Text("2024-04-28")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("历史记录")
    }
}

// 偏好设置视图
struct PreferencesView: View {
    @State private var autoReply = false
    @State private var language = "简体中文"
    @State private var fontSize: Double = 16
    
    // 主体视图，渲染偏好设置表单
    var body: some View {
        Form {
            Section("基本设置") {
                Toggle("自动回复", isOn: $autoReply)
                Picker("语言", selection: $language) {
                    Text("简体中文").tag("简体中文")
                    Text("English").tag("English")
                }
            }
            
            Section("显示") {
                VStack {
                    Text("字体大小: \(Int(fontSize))")
                    Slider(value: $fontSize, in: 12...24, step: 1)
                }
            }
        }
        .navigationTitle("偏好设置")
    }
}

// 聊天设置视图
struct ChatSettingsView: View {
    @State private var enableSound = true
    @State private var enableVibration = true
    @State private var messagePreview = true
    
    var body: some View {
        Form {
            Section("通知") {
                Toggle("声音", isOn: $enableSound)
                Toggle("振动", isOn: $enableVibration)
                Toggle("消息预览", isOn: $messagePreview)
            }
            
            Section("聊天记录") {
                Button("清空聊天记录") {
                    // TODO: 实现清空聊天记录功能
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("聊天设置")
    }
} 