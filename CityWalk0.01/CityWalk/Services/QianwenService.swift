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
class QianwenService {
    static let shared = QianwenService() // 单例
    
    private init() {}
    
    private let apiKey = "sk-7c54a7c880bc41c29bb571fd2c348488" // API密钥
    private let baseURL = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation" // API基础地址
    
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
            "model": "qwen-turbo",
            "input": [
                "messages": [
                    [
                        "role": "user",
                        "content": text
                    ]
                ]
            ],
            "parameters": [
                "incremental_output": true // 官方推荐流式参数
            ]
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
            "model": "qwen-turbo",
            "input": [
                "messages": [
                    [
                        "role": "user",
                        "content": query
                    ]
                ]
            ],
            "parameters": [
                "incremental_output": true // 官方推荐流式参数
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
            
            print("Request URL: \(endpoint)")
            print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
            print("Request Body: \(String(data: jsonData, encoding: .utf8) ?? "")")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    onComplete(QianwenError.networkError(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Response status code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 401 {
                        print("Unauthorized: Check your API key")
                        onComplete(QianwenError.unauthorized)
                        return
                    }
                }
                
                guard let data = data else {
                    print("No data received")
                    onComplete(QianwenError.invalidResponse)
                    return
                }
                
                let responseString = String(data: data, encoding: .utf8) ?? ""
                print("Raw response: \(responseString)")
                
                let lines = responseString.components(separatedBy: "\n")
                var receivedAnyData = false
                
                for line in lines {
                    guard !line.isEmpty else { continue }
                    if line.hasPrefix("data: ") {
                        let jsonString = String(line.dropFirst(6))
                        if let jsonData = jsonString.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                           let output = json["output"] as? [String: Any],
                           let text = output["text"] as? String,
                           !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            receivedAnyData = true
                            DispatchQueue.main.async {
                                onReceive(text)
                            }
                        }
                    }
                }
                
                if !receivedAnyData {
                    print("No valid data found in response")
                    onComplete(nil)
                } else {
                    onComplete(nil)
                }
            }
            
            task.resume()
            
        } catch {
            print("JSON serialization error: \(error)")
            onComplete(error)
        }
    }
} 