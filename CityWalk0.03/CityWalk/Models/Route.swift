import Foundation

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let imageName: String? // 可选图片名
}

struct Route {
    let title: String
    let author: String
    let description: String
    let places: [Place]
} 