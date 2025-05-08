import Foundation

struct Message: Identifiable {
    let id = UUID()
    var content: String
    let isUser: Bool
    let timestamp: Date
} 