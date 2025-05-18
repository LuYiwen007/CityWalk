//
//  CityWalkApp.swift
//  CityWalk
//
//  Created by 卢绎文 on 2025/4/25.
//

import SwiftUI
import SwiftData
import AMapFoundationKit

// 新增AppDelegate类用于高德Key初始化
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AMapServices.updatePrivacyShow(true, privacyInfo: true) // 新增：同意展示隐私政策
        AMapServices.updatePrivacyAgree(true) // 新增：同意隐私政策
        AMapServices.shared().apiKey = "ea6ffe534577fb90a8ce52a72c0aa121"
        return true
    }
}

// 应用程序主入口，负责全局数据容器和主窗口
@main
struct CityWalkApp: App {
    // 全局数据模型容器，负责数据持久化
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            // 创建数据容器
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // 主体视图，渲染主窗口和注入数据容器
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
