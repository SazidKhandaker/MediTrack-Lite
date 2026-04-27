import 'package:flutter/material.dart';

class WaterState {

  final String label;
  final String image;
  final Color color;
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> tips;

  WaterState({
    required this.label,
    required this.image,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.tips,
  });
}