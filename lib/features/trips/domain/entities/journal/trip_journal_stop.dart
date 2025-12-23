import 'package:flutter/material.dart';

class TripJournalStop {
  final String title;
  final String subtitle; // ex: Vietnam
  final ImageProvider image;

  final int likes;
  final int comments;
  final int photos;
  final int checkins;

  const TripJournalStop({
    required this.title,
    required this.subtitle,
    required this.image,
    this.likes = 0,
    this.comments = 0,
    this.photos = 0,
    this.checkins = 0,
  });
}
