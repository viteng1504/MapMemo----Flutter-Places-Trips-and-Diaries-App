import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../my_local_storage.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/entities/user_position.dart';

class PlaceDetailsScreen extends StatefulWidget {
  const PlaceDetailsScreen({super.key});

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  late UserPosition userPosition;
  List<Uint8List> images = [];
  final ImagePicker picker = ImagePicker();
  final TextEditingController name = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController address = TextEditingController();
  String? nameError;
  String? descError;
  String? addressError;
  // final TextEditingController city = TextEditingController();
  // final TextEditingController country = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        userPosition =
            ModalRoute.of(context)!.settings.arguments as UserPosition;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    name.dispose();
    description.dispose();
    address.dispose();
  }

  Future<void> pickImages() async {
    final List<XFile> imagesList = await picker.pickMultiImage();

    final List<Uint8List> imageBytes = [];

    for (final image in imagesList) {
      imageBytes.add(await image.readAsBytes());
    }

    setState(() {
      images = imageBytes;
    });
  }

  void randomPlace() {
    final random = Random();

    // Tên địa điểm (place name)
    final placeNames = [
      "Vincom Center",
      "Landmark 81",
      "Bến Nhà Rồng",
      "Cầu Rồng",
      "Hồ Gươm",
      "Chợ Bến Thành",
      "Nhà Thờ Đức Bà",
      "Bà Nà Hills",
      "Phố cổ Hội An",
    ];

    // Mô tả địa điểm
    final placeDescriptions = [
      "Một địa điểm nổi tiếng thu hút rất nhiều du khách.",
      "Nơi có kiến trúc độc đáo và cảnh quan đẹp.",
      "Địa điểm phù hợp để tham quan và chụp ảnh.",
      "Nơi mang nhiều giá trị văn hoá và lịch sử.",
      "Không gian rộng rãi, hiện đại và sầm uất.",
    ];

    // Địa chỉ
    final placeAddresses = [
      "Quận 1, TP. Hồ Chí Minh",
      "Bình Thạnh, TP. Hồ Chí Minh",
      "Hoàn Kiếm, Hà Nội",
      "Sơn Trà, Đà Nẵng",
      "Hội An, Quảng Nam",
      "Hải Châu, Đà Nẵng",
    ];

    name.text = placeNames[random.nextInt(placeNames.length)];
    description.text =
        placeDescriptions[random.nextInt(placeDescriptions.length)];
    address.text = placeAddresses[random.nextInt(placeAddresses.length)];
  }

  void savePlace() {
    setState(() {
      nameError = name.text.trim().isEmpty ? "Can not empty" : null;
      descError = description.text.trim().isEmpty ? "Can not empty" : null;
      addressError = address.text.trim().isEmpty ? "Can not empty" : null;
    });
    MyLocalStorage.printPlacesData();

    if (nameError != null || descError != null || addressError != null) return;

    try {
      final place = PlaceEntity(
        id: const Uuid().v4(),
        name: name.text,
        description: description.text,
        lat: userPosition.lat,
        lng: userPosition.lng,
        address: address.text,
        // city: "Hà Nội",
        // country: "Việt Nam",
        images: [],
        createdAt: DateTime.now(),
      );

      debugPrint("Place: ------- ${place.toString()}");
      MyLocalStorage.places.add(place);

      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Some thing is not right")));
    }

    MyLocalStorage.printPlacesData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [],
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: name,
                decoration: InputDecoration(
                  labelText: "place name",
                  errorText: nameError,
                ),
              ),

              TextField(
                controller: description,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: "description",
                  errorText: descError,
                ),
              ),

              TextField(
                controller: address,
                decoration: InputDecoration(
                  labelText: "address",
                  errorText: addressError,
                ),
              ),

              // const TextField(
              //   decoration: InputDecoration(labelText: "place name"),
              // ),
              ElevatedButton(
                onPressed: randomPlace,
                child: const Text("Random place"),
              ),

              ElevatedButton(
                onPressed: () {
                  pickImages();
                },
                child: const Text("Pick images"),
              ),
              images.isEmpty
                  ? const CircularProgressIndicator()
                  : Wrap(
                      spacing: 10,
                      children: List.generate(images.length, (index) {
                        return Image.memory(
                          images[index],
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                        );
                      }),
                    ),

              ElevatedButton(onPressed: savePlace, child: const Text("save")),
            ],
          ),
        ),
      ),
    );
  }
}
