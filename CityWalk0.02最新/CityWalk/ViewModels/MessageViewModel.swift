import Foundation
import SwiftUI

@MainActor
class MessageViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    
    private let qianwenService: QianwenService
    private var lastBotText: String = ""
    private var currentBotText: String = ""
    
    init(qianwenService: QianwenService = .shared) {
        self.qianwenService = qianwenService
        
        // 添加一些测试消息
        messages = [
            Message(content: "你好! ", isUser: false, timestamp: Date()),
            Message(content: "Hi! ", isUser: true, timestamp: Date()),
            Message(content: "今天天气不错", isUser: false, timestamp: Date())
        ]
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(content: inputText, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        let botMessage = Message(content: "", isUser: false, timestamp: Date())
        messages.append(botMessage)
        
        let userInput = inputText
        inputText = ""
        isLoading = true
        lastBotText = ""
        currentBotText = ""
        
        qianwenService.streamMessage(
            query: userInput,
            onReceive: { [weak self] text in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.currentBotText += text
                    if let lastMessage = self.messages.last {
                        var updatedMessage = lastMessage
                        updatedMessage.content = self.currentBotText
                        if let index = self.messages.lastIndex(where: { $0.id == lastMessage.id }) {
                            self.messages[index] = updatedMessage
                        }
                    }
                }
            },
            onComplete: { [weak self] error in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.isLoading = false
                    self.lastBotText = ""
                    self.currentBotText = ""
                    if let error = error {
                        let errorMessage: String
                        switch error {
                        case QianwenError.invalidURL:
                            errorMessage = "无效的服务器地址"
                        case QianwenError.networkError(let underlyingError):
                            errorMessage = "网络错误: \(underlyingError.localizedDescription)"
                        case QianwenError.invalidResponse:
                            errorMessage = "服务器响应无效"
                        case QianwenError.unauthorized:
                            errorMessage = "API密钥无效或已过期"
                        case QianwenError.unknown:
                            errorMessage = "未知错误"
                        default:
                            errorMessage = "发生错误: \(error.localizedDescription)"
                        }
                        let errorMsg = Message(content: errorMessage, isUser: false, timestamp: Date())
                        self.messages.append(errorMsg)
                    }
                }
            }
        )
    }
    
    func sendImageMessage(data: Data) {
        // 1. 先将图片以base64编码
        let base64String = data.base64EncodedString()
        // 2. 构造图片消息内容（可根据大模型API要求调整）
        let imagePrompt = "[图片]" // 可自定义提示词
        let userMessage = Message(content: imagePrompt, isUser: true, timestamp: Date(), imageData: data)
        messages.append(userMessage)
        let botMessage = Message(content: "", isUser: false, timestamp: Date())
        messages.append(botMessage)
        isLoading = true
        lastBotText = ""
        currentBotText = ""
        // 3. 发送图片base64字符串给大模型（如API支持图片，可直接传递base64，否则可自定义协议）
        qianwenService.streamMessage(
            query: "用户发送了一张图片，base64内容如下：\n" + base64String,
            onReceive: { [weak self] text in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.currentBotText += text
                    if let lastMessage = self.messages.last {
                        var updatedMessage = lastMessage
                        updatedMessage.content = self.currentBotText
                        if let index = self.messages.lastIndex(where: { $0.id == lastMessage.id }) {
                            self.messages[index] = updatedMessage
                        }
                    }
                }
            },
            onComplete: { [weak self] error in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.isLoading = false
                    self.lastBotText = ""
                    self.currentBotText = ""
                    if let error = error {
                        let errorMessage: String
                        switch error {
                        case QianwenError.invalidURL:
                            errorMessage = "无效的服务器地址"
                        case QianwenError.networkError(let underlyingError):
                            errorMessage = "网络错误: \(underlyingError.localizedDescription)"
                        case QianwenError.invalidResponse:
                            errorMessage = "服务器响应无效"
                        case QianwenError.unauthorized:
                            errorMessage = "API密钥无效或已过期"
                        case QianwenError.unknown:
                            errorMessage = "未知错误"
                        default:
                            errorMessage = "发生错误: \(error.localizedDescription)"
                        }
                        let errorMsg = Message(content: errorMessage, isUser: false, timestamp: Date())
                        self.messages.append(errorMsg)
                    }
                }
            }
        )
    }
} 
