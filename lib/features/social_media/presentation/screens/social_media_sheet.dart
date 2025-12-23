import 'package:flutter/material.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/theme/app_colors.dart'; // Giữ lại import của bạn

// --- WIDGET CHÍNH: SOCIAL MEDIA SHEET ---
// Đặt widget này vào trong Stack của màn hình Map (đè lên Map)
class SocialMediaSheet extends StatelessWidget {
  const SocialMediaSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5, // Mở lên 50% màn hình ban đầu
      minChildSize: 0.25, // Thu nhỏ tối đa còn 15% (như cái tab nhỏ)
      maxChildSize: 1, // Kéo lên gần full màn hình
      builder: (context, scrollController) {
        // scrollController này RẤT QUAN TRỌNG, phải truyền xuống dưới
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5), // Màu nền xám nhẹ
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Column(
            children: [
              // 1. Thanh nắm (Handle bar) để người dùng biết có thể kéo
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 2. Nội dung chính (Chứa các Tab)
              Expanded(child: MainContent(scrollController: scrollController)),
            ],
          ),
        );
      },
    );
  }
}

// --- 2. MAIN CONTENT (Chứa Bottom Navigation & Logic chuyển Tab) ---
class MainContent extends StatefulWidget {
  final ScrollController scrollController; // Nhận controller từ Sheet

  const MainContent({super.key, required this.scrollController});

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Danh sách các tab, truyền controller vào từng tab
    final List<Widget> tabs = [
      ExploreTab(controller: widget.scrollController),
      MyPostTab(controller: widget.scrollController),
      FollowerTab(controller: widget.scrollController),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, // Để lộ bo góc của Container cha
      // Dùng IndexedStack để giữ trạng thái các tab khi chuyển đổi
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 10, // Tạo bóng đổ cho đẹp tách biệt với map
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'My Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Follower',
          ),
        ],
      ),
    );
  }
}

// --- 3. EXPLORE TAB ---
class ExploreTab extends StatelessWidget {
  final ScrollController controller; // Bắt buộc phải có

  const ExploreTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header giả lập AppBar (Vì nằm trong Sheet nên không dùng AppBar của Scaffold)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Explore Trips',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            ],
          ),
        ),
        const Divider(height: 1),

        // List bài viết
        Expanded(
          child: ListView.separated(
            controller: controller, // <--- Gắn Controller vào đây
            padding: EdgeInsets.zero, // Bỏ padding thừa
            itemCount: postsData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final post = postsData[index];
              return PostItem(data: post);
            },
          ),
        ),
      ],
    );
  }
}

// --- 4. MY POST TAB ---
class MyPostTab extends StatelessWidget {
  final ScrollController controller;

  const MyPostTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: ListView(
        controller: controller, // <--- Gắn Controller vào đây
        padding: EdgeInsets.zero,
        children: [
          // Header Profile
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(
                        currentUser['avatar'] as String,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            '${(currentUser['stats'] as Map)['posts']}',
                            'Posts',
                          ),
                          _buildStatItem(
                            '${(currentUser['stats'] as Map)['followers']}',
                            'Followers',
                          ),
                          _buildStatItem(
                            '${(currentUser['stats'] as Map)['following']}',
                            'Following',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentUser['name'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentUser['bio'] as String,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'My Trips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // List My Posts
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(), // Scroll theo cha
            shrinkWrap: true,
            itemCount: myPostsData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) => PostItem(data: myPostsData[index]),
          ),
          const SizedBox(
            height: 80,
          ), // Padding dưới cùng để không bị che bởi bottom nav
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

// --- 5. FOLLOWER TAB ---
class FollowerTab extends StatelessWidget {
  final ScrollController controller;

  const FollowerTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          width: double.infinity,
          child: const Text(
            'Followers',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: controller, // <--- Gắn Controller vào đây
            padding: EdgeInsets.zero,
            itemCount: followersData.length,
            itemBuilder: (context, index) {
              final user = followersData[index];
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.only(bottom: 1),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage(AppImages.danang),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Text(
                            'Started following you',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user['isFollowing'] as bool
                            ? Colors.grey[200]
                            : AppColors.primary,
                        foregroundColor: user['isFollowing'] as bool
                            ? Colors.black
                            : Colors.white,
                        elevation: 0,
                      ),
                      child: Text(
                        user['isFollowing'] as bool ? 'Following' : 'Follow',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- 6. POST ITEM (Giữ nguyên logic cũ, chỉ cập nhật xử lý ảnh) ---
class PostItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const PostItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(data['user']['avatar']),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['user']['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      data['user']['time'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(data['caption'], style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(height: 12),
          // Trip Card
          _buildTripCard(data['trip']),
          const SizedBox(height: 12),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 26,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text('${data['likes']}'),
                const SizedBox(width: 24),
                const Icon(
                  Icons.bookmark_add_outlined,
                  size: 26,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text('${data['adds']} Add Trip'),
                const Spacer(),
                const Icon(Icons.share_outlined, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              trip['image'],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'TRIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trip['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    trip['date'],
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- DỮ LIỆU GIẢ LẬP (MOCK DATA) ---
// (Giữ nguyên phần data của bạn ở file cũ, chỉ cần paste lại vào cuối file này hoặc import)
final List<Map<String, dynamic>> postsData = [
  // ... Paste data postsData của bạn
  {
    'user': {
      'name': 'Hoàng Nam',
      'avatar': 'https://i.pravatar.cc/150?img=33',
      'time': '30 phút trước',
    },
    'caption': 'Hà Giang mùa này đẹp quá!',
    'trip': {
      'title': 'Hà Giang Loop',
      'date': '10/11/2023',
      'image':
          'https://images.unsplash.com/photo-1598135753163-6167c1a1ad65?auto=format&fit=crop&w=800',
    },
    'likes': 1540,
    'adds': 420,
  },
  // Thêm dữ liệu khác nếu cần...
];
final currentUser = {
  'name': 'Tuấn Anh',
  'avatar': 'https://i.pravatar.cc/150?img=11',
  'bio': 'Travel Blogger',
  'stats': {'posts': 12, 'followers': '5.4k', 'following': 120},
};
final myPostsData = postsData; // Giả lập lấy lại postsData
final followersData = [
  {
    'name': 'Nguyễn Thu Hà',
    'avatar': 'https://i.pravatar.cc/150?img=5',
    'isFollowing': true,
  },
  {
    'name': 'Trần Minh Đức',
    'avatar': 'https://i.pravatar.cc/150?img=3',
    'isFollowing': false,
  },
];
