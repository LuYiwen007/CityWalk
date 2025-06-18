import SwiftUI

struct Trip: Identifiable {
    let id = UUID()
    let title: String
    let days: String
    let locations: String
    let image: Image?
    let avatar: Image?
    let date: Date
}

struct TripView: View {
    // 示例数据
    @State private var currentTrip = Trip(title: "日本文艺历史8天行程", days: "8天7晚", locations: "30个地点", image: Image("trip_sample"), avatar: Image("avatar_sample"), date: Date())
    @State private var historyTrips: [Trip] = [
        Trip(title: "苏州园林3日游", days: "3天2晚", locations: "12个地点", image: nil, avatar: nil, date: Date().addingTimeInterval(-86400*10)),
        Trip(title: "杭州西湖2日游", days: "2天1晚", locations: "8个地点", image: nil, avatar: nil, date: Date().addingTimeInterval(-86400*20))
    ]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 当前行程
                Text("当前行程")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.leading, 18)
                TripCardView(trip: currentTrip)
                    .padding(.horizontal, 14)
                // 历史行程
                Text("历史行程")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.leading, 18)
                VStack(spacing: 18) {
                    ForEach(historyTrips.sorted(by: { $0.date > $1.date })) { trip in
                        TripCardView(trip: trip)
                    }
                }
                .padding(.horizontal, 14)
            }
            .padding(.top, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct TripCardView: View {
    let trip: Trip
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(red: 1.0, green: 0.89, blue: 0.93, opacity: 1.0))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(trip.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                        HStack(spacing: 16) {
                            Text(trip.days)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.gray)
                            Text(trip.locations)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    // 右上图片区域
                    if let img = trip.image {
                        img
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.top, 6)
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemGray5))
                            .frame(width: 90, height: 60)
                            .padding(.top, 6)
                    }
                }
                Spacer(minLength: 0)
                HStack(spacing: 10) {
                    // 头像区域
                    if let avatar = trip.avatar {
                        avatar
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.gray)
                    }
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 22, height: 22)
                            .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1))
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.bottom, 8)
            }
            .padding(20)
        }
        .frame(height: 150)
    }
} 