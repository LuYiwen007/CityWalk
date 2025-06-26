import SwiftUI

struct RouteDetailView: View {
    let routeTitle: String
    
    // 地点数组（可变）
    @State private var locations = [
        "恒宝广场",
        "禄运茶居·手工点心(恒宝广场店)",
        "广州永庆坊",
        "陈家祠堂",
        "沙面岛",
        "广州石室耶稣圣心大教堂",
        "赵记传承(一德路店)",
        "啫八(远洋财富商务中心店)"
    ]
    @State private var selectedTab = 0 // 0 表示总览，1...表示各个地点

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
                    // 总览和地点tabs
                    VStack(alignment: .leading, spacing: 8) {
                        // Tab栏
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // 总览tab
                                Button(action: {
                                    selectedTab = 0
                                }) {
                                    VStack(spacing: 4) {
                                        Text("总览")
                                            .font(.headline)
                                            .foregroundColor(selectedTab == 0 ? .blue : .primary)
                                        Rectangle()
                                            .frame(width: 30, height: 4)
                                            .foregroundColor(selectedTab == 0 ? .blue : .clear)
                                            .cornerRadius(2)
                                    }
                                }
                                
                                // 各个地点tabs
                                ForEach(Array(locations.enumerated()), id: \.offset) { index, location in
                                    Button(action: {
                                        selectedTab = index + 1
                                    }) {
                                        VStack(spacing: 4) {
                                            Text(location)
                                                .font(.caption)
                                                .foregroundColor(selectedTab == index + 1 ? .blue : .primary)
                                                .lineLimit(1)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Rectangle()
                                                .frame(width: 30, height: 4)
                                                .foregroundColor(selectedTab == index + 1 ? .blue : .clear)
                                                .cornerRadius(2)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)

                    // 根据选中的tab显示不同内容
                    if selectedTab == 0 {
                        // 总览内容
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "map.fill")
                                    .foregroundColor(.blue)
                                Text("行程概览")
                                    .font(.headline)
                            }
                            .padding(.bottom, 8)
                            
                            // 地点列表
                            VStack(spacing: 12) {
                                ForEach(Array(locations.enumerated()), id: \ .offset) { index, location in
                                    HStack(spacing: 12) {
                                        // 序号圆圈
                                        ZStack {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 30, height: 30)
                                            Text("\(index + 1)")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        // 地点信息
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(location)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            Text("第\(index + 1)站")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        // 负号按钮
                                        Button(action: {
                                            locations.remove(at: index)
                                            // 如果当前tab被删，跳回总览tab
                                            if selectedTab == index + 1 {
                                                selectedTab = 0
                                            } else if selectedTab > locations.count {
                                                selectedTab = 0
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.title3)
                                        }
                                        // 箭头图标（除了最后一个地点）
                                        if index < locations.count - 1 {
                                            Image(systemName: "arrow.down")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // 具体地点内容
                        let locationIndex = selectedTab - 1
                        let locationName = locations[locationIndex]
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // 地点图片
                            Image(systemName: "photo")
                                .font(.system(size: 200))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    Text("\(locationName) 图片")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                )
                            
                            // 地点介绍文字
                            VStack(alignment: .leading, spacing: 8) {
                                Text(locationName)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("这是 \(locationName) 的详细介绍。这里可以包含该地点的历史背景、特色亮点、参观建议、开放时间、门票信息等详细信息。")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineSpacing(4)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
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
                
                Button(action: {
                    selectedTab = 0 // 跳回总览tab
                }) {
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
