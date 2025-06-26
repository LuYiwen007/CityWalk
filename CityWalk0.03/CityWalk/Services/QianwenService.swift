import Foundation

// 通义千问相关错误类型定义
enum QianwenError: Error {
    case invalidURL // URL无效
    case networkError(Error) // 网络错误
    case invalidResponse // 响应无效
    case unauthorized // 未授权
    case unknown // 未知错误
}

// 通义千问服务，负责与阿里云通义千问API进行网络通信
class QianwenService: NSObject, URLSessionDataDelegate {
    static let shared = QianwenService() // 单例
    
    private var receivedData: Data = Data()
    private var dataTask: URLSessionDataTask?
    private var onReceive: ((String) -> Void)?
    private var onComplete: ((Error?) -> Void)?
    
    private override init() {}
    
    private let apiKey = "sk-7c54a7c880bc41c29bb571fd2c348488" // API密钥
    private let baseURL = "https://dashscope.aliyuncs.com/api/v1/apps/7188b1ce823343f9b919d61f0a5f7d59/completion" // API基础地址
    // private let appId = "7188b1ce823343f9b919d61f0a5f7d59" // 用户阿里云应用ID

    // 发送消息，返回原始响应字符串
    func sendMessage(_ text: String) async throws -> String {
        let endpoint = baseURL
        guard let url = URL(string: endpoint) else {
            throw QianwenError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("enable", forHTTPHeaderField: "X-DashScope-SSE") // 新增SSE流式输出Header

        let body: [String: Any] = [
            "input": [
                "prompt": text
            ],
            "parameters": [
                "incremental_output": true
            ],
            "debug": [:]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw QianwenError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            throw QianwenError.invalidResponse
        }

        guard let responseString = String(data: data, encoding: .utf8) else {
            throw QianwenError.invalidResponse
        }

        return responseString
    }

    // 以流式方式发送消息，逐步回调onReceive，结束时回调onComplete
    func streamMessage(
        query: String,
        onReceive: @escaping (String) -> Void,
        onComplete: @escaping (Error?) -> Void
    ) {
        self.onReceive = onReceive
        self.onComplete = onComplete
        self.receivedData = Data()

        let endpoint = baseURL
        guard let url = URL(string: endpoint) else {
            onComplete(QianwenError.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("enable", forHTTPHeaderField: "X-DashScope-SSE") // 新增SSE流式输出Header

        let body: [String: Any] = [
            "input": [
                "prompt": query
            ],
            "parameters": [
                "incremental_output": true
            ],
            "debug": [:]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
            
            print("Request URL: \(endpoint)")
            print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
            print("Request Body: \(String(data: jsonData, encoding: .utf8) ?? "")")
            
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            dataTask = session.dataTask(with: request)
            dataTask?.resume()
            
        } catch {
            print("JSON serialization error: \(error)")
            onComplete(error)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
        
        if let string = String(data: data, encoding: .utf8) {
            let lines = string.components(separatedBy: "\n")
            for line in lines {
                guard !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
                if line.hasPrefix("data:") {
                    let jsonString = String(line.dropFirst(5))
                    if let jsonData = jsonString.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                       let output = json["output"] as? [String: Any],
                       let text = output["text"] as? String {
                        DispatchQueue.main.async {
                            self.onReceive?(text)
                        }
                    }
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            self.onComplete?(QianwenError.networkError(error))
        } else {
            self.onComplete?(nil)
        }
        
        // 清理资源
        self.receivedData = Data()
        self.onReceive = nil
        self.onComplete = nil
        self.dataTask = nil
    }
} 
