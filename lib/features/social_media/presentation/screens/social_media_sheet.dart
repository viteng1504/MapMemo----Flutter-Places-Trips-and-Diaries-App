import 'package:flutter/material.dart';

// Model dữ liệu giả lập
class PostModel {
  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String caption;
  final String tripImage;
  final String tripTitle;
  final String tripLocation;
  final int likeCount;
  final int addCount;

  PostModel({
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.caption,
    required this.tripImage,
    required this.tripTitle,
    required this.tripLocation,
    required this.likeCount,
    required this.addCount,
  });
}

class SocialMediaSheet extends StatefulWidget {
  const SocialMediaSheet({super.key});

  @override
  State<SocialMediaSheet> createState() => _SocialMediaSheetState();
}

class _SocialMediaSheetState extends State<SocialMediaSheet> {
  // Dữ liệu mẫu
  final List<PostModel> posts = [
    PostModel(
      userName: "Minh Tuấn",
      userAvatar: "https://i.pravatar.cc/150?img=11",
      timeAgo: "2 giờ trước",
      caption:
          "Chuyến đi Đà Lạt chữa lành tâm hồn. Không khí thật tuyệt vời! 🌲☕️",
      tripImage: "https://picsum.photos/id/10/600/300",
      tripTitle: "Đà Lạt - Thành phố ngàn hoa",
      tripLocation: "Lâm Đồng, Việt Nam",
      likeCount: 1240,
      addCount: 350,
    ),
    PostModel(
      userName: "Lan Chi",
      userAvatar: "https://i.pravatar.cc/150?img=5",
      timeAgo: "5 giờ trước",
      caption:
          "Mọi người nhất định phải thử cung đường này nhé, biển xanh cát trắng nắng vàng. 🌊☀️",
      tripImage: "https://picsum.photos/id/15/600/300",
      tripTitle: "Khám phá Kỳ Co - Eo Gió",
      tripLocation: "Quy Nhơn, Bình Định",
      likeCount: 856,
      addCount: 120,
    ),
    PostModel(
      userName: "Phượt Bụi",
      userAvatar: "https://i.pravatar.cc/150?img=3",
      timeAgo: "1 ngày trước",
      caption:
          "Săn mây Tà Xùa thành công mỹ mãn. Trip này mình đi 2N1Đ chi phí cực rẻ.",
      tripImage: "https://picsum.photos/id/29/600/300",
      tripTitle: "Săn mây Tà Xùa",
      tripLocation: "Sơn La, Việt Nam",
      likeCount: 2300,
      addCount: 890,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // --- PHẦN CHÍNH: DraggableScrollableSheet ---
        DraggableScrollableSheet(
          initialChildSize: 0.6, // Chiều cao ban đầu (60% màn hình)
          minChildSize: 0.3, // Chiều cao thấp nhất khi kéo xuống
          maxChildSize: 0.95, // Chiều cao tối đa khi kéo lên
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5), // Màu nền xám nhẹ
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Thanh Handle (Thanh nắm)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Danh sách bài đăng
                  Expanded(
                    child: ListView.builder(
                      controller:
                          scrollController, // QUAN TRỌNG: Phải gắn controller này
                      itemCount: posts.length,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemBuilder: (context, index) {
                        return _buildPostItem(posts[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Widget hiển thị từng bài đăng
  Widget _buildPostItem(PostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Avatar + Tên + Thời gian
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(post.userAvatar),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      post.timeAgo,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Caption
          Text(post.caption, style: const TextStyle(fontSize: 14, height: 1.4)),

          const SizedBox(height: 12),

          // 3. Trip Embed (Bài trip đính kèm)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            clipBehavior: Clip.antiAlias, // Cắt ảnh bo góc
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh Cover của Trip
                Image.network(
                  post.tripImage,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 150, color: Colors.grey[300]),
                ),
                // Thông tin Trip
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.tripTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    post.tripLocation,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 4. Stats: Tim và Add Trip
          Row(
            children: [
              _buildStatItem(
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                color: Colors.red,
                count: post.likeCount,
                label: "thích",
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.bookmark_add_outlined,
                activeIcon: Icons.bookmark_added,
                color: Colors.blue,
                count: post.addCount,
                label: "đã thêm",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget con hiển thị icon và số lượng
  Widget _buildStatItem({
    required IconData icon,
    required IconData activeIcon,
    required Color color,
    required int count,
    required String label,
  }) {
    return InkWell(
      onTap: () {
        // Xử lý logic like/add tại đây
      },
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            "$count",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }
}
