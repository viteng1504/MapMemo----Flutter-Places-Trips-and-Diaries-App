import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../data/data_sources/remote/trip_planner_service.dart';
import '../../../../data/models/trip_model.dart';
import '../../../../domain/entities/planner/planner_stop_entity.dart';
import 'journal_diary_section_card.dart';
import 'journal_edit_diary_bottom_sheet.dart';
import 'journal_image_section.dart';
import 'journal_primary_button.dart';
import 'journal_title_section.dart';

class StopDetailBottomSheet extends StatefulWidget {
  final PlannerStopEntity stop;
  final TripModel tripModel;

  const StopDetailBottomSheet({
    super.key,
    required this.stop,
    required this.tripModel,
  });

  @override
  State<StopDetailBottomSheet> createState() => _StopDetailBottomSheetState();
}

class _StopDetailBottomSheetState extends State<StopDetailBottomSheet> {
  List<ImageProvider> _images = [];
  late String _diaryContent;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController controller = TextEditingController();

  final _service = TripPlannerService(Supabase.instance.client);
  @override
  void initState() {
    super.initState();

    _images = [];
    controller.text = "";
    _diaryContent = "";

    getStopImages();
    getDiary();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    controller.dispose();
  }

  Future<void> getStopImages() async {
    final List<String> images = await _service.getStopImages(widget.stop.id);
    setState(() {
      _images = images.map((url) => NetworkImage(url)).toList();
    });
  }

  Future<void> getDiary() async {
    final diaryText = await _service.getStopDiary(widget.stop.id);

    setState(() {
      controller.text = diaryText ?? "";
      _diaryContent = diaryText ?? "";
    });
  }

  // 2. HÀM CHỌN ẢNH
  Future<void> _pickImage() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isEmpty) return;

      final List<File> fileImages = pickedFiles
          .map((xFile) => File(xFile.path))
          .toList();

      final images = await _service.uploadStopImages(
        stopId: widget.stop.id,
        imageFiles: fileImages,
      );

      setState(() {
        // Thêm các FileImage mới vào danh sách hiện tại
        setState(() {
          _images = images.map((url) => NetworkImage(url)).toList();
        });
      });

      // Tùy chọn: Sau khi upload xong có thể gọi lại getStopImages()
      // để đồng bộ lại URL từ Server nếu cần.
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

  Future<void> onSave() async {
    setState(() {
      _diaryContent = controller.text;
      _service.updateStopDiary(
        stopId: widget.stop.id,
        diaryText: controller.text,
        stopName: widget.stop.name,
        tripId: widget.tripModel.id,
      );
    });
    Navigator.pop(context);
  }

  // 3. HÀM SỬA DIARY (Hiện Dialog)
  void _showEditDiaryDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Để đẩy lên khi có bàn phím
      backgroundColor: Colors.transparent,
      builder: (context) => JournalEditDiaryBottomSheet(
        controller: controller,
        diaryContent: _diaryContent,
        onSave: onSave,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FB), // Màu nền sáng hơn
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ), // Bo góc lớn hơn
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Grab handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
                  children: [
                    // --- SECTION: IMAGE CAROUSEL ---
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: AspectRatio(
                            aspectRatio: 16 / 16,
                            child: JournalImageSection(
                              images: _images,
                              onAddTap: _pickImage,
                            ),
                          ),
                        ),
                        // Nút Add Image đè lên ảnh
                        if (_images.isNotEmpty)
                          Positioned(
                            right: 12,
                            bottom: 24,
                            child: _AddImageButton(
                              onTap: () {
                                _pickImage();
                              },
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- SECTION: TITLE ---
                    JournalTitleSection(title: widget.stop.name),
                    const SizedBox(height: 24),

                    // --- SECTION: DIARY ---
                    JournalDiarySectionCard(
                      title: "My Diary",
                      icon: Icons.book_rounded,
                      child: Text(
                        (_diaryContent.trim().isEmpty)
                            ? "There are no log contents for this location yet. Write down your beautiful memories!"
                            : _diaryContent,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- SECTION: ACTIONS ---
                    Row(
                      children: [
                        Expanded(
                          child: JournalPrimaryButton(
                            text: "Fly to this stop",
                            icon: Icons.explore_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _SquareButton(
                          icon: Icons.edit_note_rounded,
                          onTap: () {
                            _showEditDiaryDialog();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddImageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          // blurRadius: 10, // Giả lập glassmorphism nhẹ
        ),
        child: const Row(
          children: [
            Icon(
              Icons.add_photo_alternate_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            SizedBox(width: 6),
            Text(
              "Add Photo",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}
