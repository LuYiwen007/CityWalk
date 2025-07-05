import Foundation
import CoreLocation

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let imageName: String? // 可选图片名
    let coordinate: CLLocationCoordinate2D?
}

struct Route: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let description: String
    let places: [Place]
} 