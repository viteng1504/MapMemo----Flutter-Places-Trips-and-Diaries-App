import 'package:flutter/material.dart';

import 'journal_gradient_overlay.dart';

class JournalImageSection extends StatefulWidget {
  final List<ImageProvider> images;
  final VoidCallback? onAddTap;

  const JournalImageSection({super.key, required this.images, this.onAddTap});

  @override
  State<JournalImageSection> createState() => JournalImageSectionState();
}

class JournalImageSectionState extends State<JournalImageSection> {
  final PageController _pc = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. TRƯỜNG HỢP KHÔNG CÓ ẢNH -> HIỆN NÚT ADD TO
    if (widget.images.isEmpty) {
      return Material(
        color: const Color(0xFFEAECEF), // Màu nền xám nhẹ
        child: InkWell(
          onTap: widget.onAddTap, // Gọi hàm khi bấm vào vùng này
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_a_photo_rounded,
                    size: 32,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Add images",
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. TRƯỜNG HỢP CÓ ẢNH -> HIỆN CAROUSEL NHƯ CŨ
    return Stack(
      children: [
        PageView.builder(
          controller: _pc,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) =>
              Image(image: widget.images[i], fit: BoxFit.cover),
        ),

        // Dot indicators
        if (widget.images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _index == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(_index == i ? 1.0 : 0.5),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      // Thêm chút bóng cho dot để dễ nhìn trên nền ảnh sáng
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Gradient overlay
        const JournalGradientOverlay(),
      ],
    );
  }
}
