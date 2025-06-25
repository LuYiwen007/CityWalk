import SwiftUI

struct RouteDetailView: View {
    let routeTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Text("越秀公园1小时徒步路线")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                HStack(spacing: -10) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 总览
                    VStack(alignment: .leading, spacing: 8) {
                        Text("总览")
                            .font(.headline)
                        Rectangle()
                            .frame(width: 30, height: 4)
                            .foregroundColor(.blue)
                            .cornerRadius(2)
                    }
                    .padding(.horizontal)

                    // 行程概览
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "map.fill")
                                .foregroundColor(.blue)
                            Text("行程概览")
                                .font(.headline)
                        }
                        .padding(.bottom, 8)
                        
                        Text("恒宝广场 → 禄运茶居·手工点心(恒宝广场店) → 广州永庆坊 → 陈家祠堂 → 沙面岛 → 广州石室耶稣圣心大教堂 → 赵记传承(一德路店) → 啫八(远洋财富商务中心店)")
                            .font(.body)
                            .lineSpacing(6)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // 待规划
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "pencil.and.ruler.fill")
                                .foregroundColor(.orange)
                            Text("待规划")
                                .font(.headline)
                        }
                        Text("行程备注")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        
                        Text("广州是一座充满历史韵味和美食的城市。本次行程将带你领略老广的市井生活，品尝地道美食。")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()

            // 底部按钮
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemGray5))
                .clipShape(Circle())
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("编辑路线")
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(25)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
} 