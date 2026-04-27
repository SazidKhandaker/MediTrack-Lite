import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class AISuggestionCard extends StatelessWidget {
  final String lang;
  final double suggestion;
  final VoidCallback onApply;

  const AISuggestionCard({
    super.key,
    required this.lang,
    required this.suggestion,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                lang == "bn" ? "স্মার্ট পরামর্শ" : "Smart Suggestion",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "${suggestion.toStringAsFixed(1)} L",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(
            lang == "bn"
                ? "আপনার শরীরের জন্য উপযুক্ত"
                : "Recommended for your body",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

    ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    elevation: 5,
    ),
    onPressed: onApply,
    child: Text(
    lang == "bn" ? "ওজন পরিবর্তন করুন" : "Edit Weight",
    style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    ),
    ),
    )

        ],
      ),
    );
  }

}