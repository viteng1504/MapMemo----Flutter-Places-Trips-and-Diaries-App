import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/widgets/my_primary_button.dart';
import '../../../../my_local_storage.dart';
import '../../data/data_sources/remote/trip_service.dart';
import '../../domain/entities/trip_entity.dart';
import '../widgets/add_trip/cover_photo_section.dart';
import '../widgets/add_trip/error_text.dart';
import '../widgets/add_trip/input_box.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final TripService _tripService = TripService(Supabase.instance.client);
  bool isLoading = false;

  final ImagePicker picker = ImagePicker();
  DateTime? startDate;
  DateTime? endDate;
  Uint8List? coverImageBytes;
  final TextEditingController tripNameController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  String tripName = "";
  String summary = "";

  bool showDateError = false;
  bool showNameError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  // COVER + DATES
                  CoverPhotoSection(
                    coverImageBytes: coverImageBytes,
                    onPickCoverPhoto: onPickCoverPhoto,
                    startDate: startDate,
                    endDate: endDate,
                    showDateError: showDateError,
                    onPickStart: pickStartDate,
                    onPickEnd: pickEndDate,
                  ),

                  const SizedBox(height: 20),

                  // NAME
                  InputBox(
                    icon: Icons.sell_outlined,
                    title: "Name your trip",
                    child: TextField(
                      controller: tripNameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (v) {
                        setState(() {
                          tripName = v;
                          showNameError = tripName.trim().isEmpty;
                        });
                      },
                    ),
                  ),

                  if (showNameError) const ErrorText("Please choose a name"),

                  const SizedBox(height: 20),

                  // SUMMARY
                  InputBox(
                    icon: Icons.menu,
                    title: "Add a short description",
                    child: TextField(
                      controller: summaryController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => setState(() => summary = v),
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildBottomButton(context),
        ],
      ),
    );
  }

  // ===============================
  // UI helpers
  // ===============================

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "New trip",
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
      ),
      actions: [
        IconButton(
          onPressed: autofillRandomData,
          icon: const Icon(Icons.auto_fix_high, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: MyPrimaryButton(
        onPressed: () {
          validateBeforeCreate(context);
        },
        label: "Create Trip",
        isLoading: isLoading,
      ),
    );
  }

  // ===============================
  // LOGIC
  // ===============================

  Future<void> pickStartDate(BuildContext context) async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(9999),
    ).then((pickDate) {
      if (pickDate == null) return;

      setState(() {
        startDate = pickDate;
      });
    });
  }

  Future<void> pickEndDate(BuildContext context) async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(9999),
    ).then((pickDate) {
      if (pickDate == null) return;

      setState(() {
        endDate = pickDate;
      });
    });
  }

  Future<void> validateBeforeCreate(BuildContext context) async {
    bool nameError = tripName.trim().isEmpty;
    bool dateError = false;

    // Validate date
    if (startDate == null || endDate == null) {
      dateError = true;
    } else {
      final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);

      if (end.isBefore(start)) {
        dateError = true;
      }
    }

    setState(() {
      showNameError = nameError;
      showDateError = dateError;
      isLoading = true;
    });

    if (nameError || dateError) return;

    if (!showNameError && !showDateError) {
      // Create trip here
      final tripId = const Uuid().v4();
      final days = (endDate != null && startDate != null)
          ? endDate!.difference(startDate!).inDays + 1
          : 0;

      final trip = TripEntity(
        id: tripId,
        name: tripName,
        summary: summary,
        startDate: startDate!,
        days: days,
        image: coverImageBytes,
      );

      final tripModel = await _tripService.addTrip(trip);

      if (!context.mounted) return;
      print("=========================add trip success");
      setState(() {
        isLoading = false;
      });

      MyLocalStorage.trips.add(tripModel);

      Navigator.pop(context, tripModel);
    }

    // Navigator.pushNamed(
    //   context,
    //   AppRoutes.tripPersonalize,
    //   arguments: TripAiRequest(
    //     tripName: tripName,
    //     tripSummary: summary,
    //     startDate: _fmt(startDate),
    //     endDate: _fmt(endDate),
    //     startDestination: "",
    //     endDestination: "",
    //     travelStyle: "",
    //   ),
    // );
  }

  void onPickCoverPhoto() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final imageBytes = await image.readAsBytes();

    setState(() {
      coverImageBytes = imageBytes;
    });
  }

  int _rand(int min, int max) {
    return min + (DateTime.now().microsecond % (max - min + 1));
  }

  void autofillRandomData() async {
    final randomNames = [
      "Discover Vietnam",
      "Summer Adventure",
      "Hidden Beaches Trip",
      "Mountain Escape",
      "Food & Culture Tour",
    ];

    final randomSummaries = [
      "A short but memorable journey.",
      "Exploring the local culture and food.",
      "An unforgettable adventure!",
      "Relaxing and enjoying beautiful landscapes.",
      "A trip full of surprises and memories.",
    ];

    // Random dates (within next 30 days)
    final now = DateTime.now();
    final randStart = now.add(Duration(days: _rand(1, 10)));
    final randEnd = randStart.add(Duration(days: _rand(2, 7)));

    // Create a random colored image as cover photo

    setState(() {
      tripName = randomNames[_rand(0, randomNames.length - 1)];
      summary = randomSummaries[_rand(0, randomSummaries.length - 1)];
      startDate = randStart;
      endDate = randEnd;

      tripNameController.text = tripName;
      summaryController.text = summary;

      showNameError = false;
      showDateError = false;
    });
  }
}
