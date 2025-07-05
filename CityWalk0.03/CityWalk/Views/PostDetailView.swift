import SwiftUI
import CoreLocation

struct PostDetailView: View {
    let post: CommunityPostItem
    // 可选：路线坐标
    var routeCoordinates: [CLLocationCoordinate2D] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 36) // 让图片整体下移
            Image(post.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 220)
                .clipped()
                .cornerRadius(16)
                .padding(.horizontal, 12)
            // 用户栏
            HStack {
                Image(post.authorImageName)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                Text(post.authorName)
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button(action: {}) {
                    Text("Follow")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            // 帖子正文
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // 标题
                    Text("米亚罗风景区太后悔了！！！后悔没早点来！")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.bottom, 2)
                    // 副标题
                    Text("米亚罗风景区真的真的真的太太太漂亮了！稻城亚丁雪山景平替，再也不用去那么远就能看到雪山了。")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.bottom, 2)
                    // 攻略标题
                    HStack(spacing: 4) {
                        Text("📌米亚罗景区攻略📕")
                            .font(.system(size: 16, weight: .bold))
                    }
                    // 1.景点介绍
                    Group {
                        Text("1.景点介绍：")
                            .font(.system(size: 16, weight: .bold))
                        + Text("米亚罗，这个藏语意为\"好玩的坝子\"的地方，位于四川省阿坝藏族羌族自治州理县境内，是中国最大的红叶风景区之一。每到秋天，这里的红叶如火，层林尽染，美不胜收。")
                            .font(.system(size: 16))
                    }
                    // 2.交通
                    Group {
                        Text("2.交通：")
                            .font(.system(size: 16, weight: .bold))
                        + Text("导航直接搜猛古村，到了之后分徒步和开车上山两种方式，看其他博主分享的徒步上山的话单边大概是3小时，徒步的话可以看到很多风景肯定也不错，但是我跟朋友是大懒鬼，果断选择开车上山[doge]  寨子里面的人说车可以直接开到虞美措这个湖这里，但是开车要做好心理准备就是路真的超级超级超级烂，全是大大小小的坑，一路都是大大小小的石头，开越野车或者SUV倒不是太担心，进山的费用一个人20元，要签协议书不能抽烟不能有明火之类的，进山之后手机就没有信号了，开车上去大概40分钟左右")
                            .font(.system(size: 16))
                    }
                    // 3.住宿推荐
                    Group {
                        Text("3.住宿推荐：")
                            .font(.system(size: 16, weight: .bold))
                        + Text("个人感觉猛古村没有什么住的地方，可以再往前开到米亚罗镇，从客栈到酒店应有尽有，旺季的话尽量提前在网上订好")
                            .font(.system(size: 16))
                    }
                    // 4.美食
                    Group {
                        Text("4.美食：")
                            .font(.system(size: 16, weight: .bold))
                        + Text("如果要去那片湖的话请自备吃的，因为进山之后就什么都没有了，猛古村里面有一个小卖部但是只买点面包和水，其他都没有，所以一定一定要提前准备，我们上去之后都看到有人在扎帐篷露营")
                            .font(.system(size: 16))
                    }
                    // 小贴士
                    Group {
                        Text("小贴士：")
                            .font(.system(size: 16, weight: .bold))
                        + Text("米亚罗地处高海拔地区，气候多变，请务必带上足够的衣物以应对可能的低温天气。")
                            .font(.system(size: 16))
                    }
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            // 点赞评论收藏区
            HStack(spacing: 24) {
                HStack(spacing: 4) {
                    Image(systemName: "heart")
                    Text("\(post.likes)")
                }
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                    Text("44")
                }
                HStack(spacing: 4) {
                    Image(systemName: "star")
                    Text("208")
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// 预览
struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(post: CommunityPostItem(imageName: "miya_luo_cover", title: "米亚罗霸王山2日", authorName: "浪迹川西", authorImageName: "avatar_langjichuanxi", likes: 45))
    }
} 