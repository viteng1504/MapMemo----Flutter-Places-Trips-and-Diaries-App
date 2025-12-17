import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_api.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../my_local_storage.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/entities/place_position.dart';
import '../widgets/add_place_details//error_text.dart';
import '../widgets/add_place_details//fancy_button.dart';
import '../widgets/add_place_details//map_preview.dart';
import '../widgets/add_place_details//place_image_picker.dart';
import '../widgets/add_place_details//place_images_grid.dart';
import '../widgets/add_place_details//place_input_card.dart';

class PlaceDetailsScreen extends StatefulWidget {
  const PlaceDetailsScreen({super.key});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  late PlacePosition position;

  String? mapUrl;
  final ImagePicker picker = ImagePicker();

  // controllers
  final name = TextEditingController();
  final description = TextEditingController();
  final address = TextEditingController();

  // errors
  String? nameError;
  String? descError;
  String? addressError;

  // images
  List<Uint8List> images = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      position = ModalRoute.of(context)!.settings.arguments as PlacePosition;

      final url = await getStaticMap(position.lng, position.lat);
      setState(() => mapUrl = url);
    });
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    address.dispose();
    super.dispose();
  }

  // =============================
  // LOGIC
  // =============================

  Future<String> getStaticMap(double lng, double lat) async {
    return "https://api.mapbox.com/styles/v1/mapbox/streets-v12/static"
        "/pin-l+ff0000($lng,$lat)/$lng,$lat,15,0/800x500"
        "?access_token=${AppApi.mapboxAccessToken}";
  }

  Future<void> pickImages() async {
    final List<XFile> list = await picker.pickMultiImage();
    final bytes = <Uint8List>[];

    for (final img in list) {
      bytes.add(await img.readAsBytes());
    }

    setState(() => images = bytes);
  }

  void randomPlace() {
    final names = ["Vincom Center", "Cầu Rồng", "Hồ Gươm", "Bà Nà Hills"];
    final descs = ["Đẹp cực!", "Rất đáng đi!", "Nổi tiếng", "Có view đẹp"];
    final addr = ["Đà Nẵng", "Hà Nội", "Hồ Chí Minh"];

    name.text = names[Random().nextInt(names.length)];
    description.text = descs[Random().nextInt(descs.length)];
    address.text = addr[Random().nextInt(addr.length)];
  }

  void savePlace() {
    setState(() {
      nameError = name.text.isEmpty ? "Required" : null;
      descError = description.text.isEmpty ? "Required" : null;
      addressError = address.text.isEmpty ? "Required" : null;
    });

    if (nameError != null || descError != null || addressError != null) return;

    final place = PlaceEntity(
      id: const Uuid().v4(),
      name: name.text,
      description: description.text,
      address: address.text,
      lat: position.lat,
      lng: position.lng,
      images: images,
      createdAt: DateTime.now(),
    );

    MyLocalStorage.places.add(place);
    Navigator.pop(context, true);
  }

  // =============================
  // UI
  // =============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Place"),
      ),

      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            MapPreview(imageUrl: mapUrl),

            const SizedBox(height: 16),

            PlaceInputCard(
              title: "Place name",
              child: TextField(
                controller: name,
                decoration: const InputDecoration(
                  hintText: "Enter place name",
                  border: InputBorder.none,
                ),
              ),
            ),
            if (nameError != null) ErrorText(nameError!),

            const SizedBox(height: 16),

            PlaceInputCard(
              title: "Description",
              child: TextField(
                maxLines: 3,
                controller: description,
                decoration: const InputDecoration(
                  hintText: "Describe this place",
                  border: InputBorder.none,
                ),
              ),
            ),
            if (descError != null) ErrorText(descError!),

            const SizedBox(height: 16),

            PlaceInputCard(
              title: "Address",
              child: TextField(
                controller: address,
                decoration: const InputDecoration(
                  hintText: "Enter address",
                  border: InputBorder.none,
                ),
              ),
            ),
            if (addressError != null) ErrorText(addressError!),

            const SizedBox(height: 16),

            PlaceImagePicker(onPick: pickImages),

            if (images.isNotEmpty)
              Wrap(
                children: [
                  const Divider(color: AppColors.border),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: PlaceImagesGrid(images: images),
                  ),
                  const Divider(color: AppColors.border),
                ],
              ),

            const SizedBox(height: 20),

            FancyButton(
              text: "Random place",
              color: Colors.blue.shade800,
              onTap: randomPlace,
            ),

            const SizedBox(height: 20),

            FancyButton(
              text: "Save",
              color: Colors.pink.shade600,
              onTap: savePlace,
            ),
          ],
        ),
      ),
    );
  }
}
