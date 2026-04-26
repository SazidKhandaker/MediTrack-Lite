import 'package:flutter/material.dart';

class MedicineDetailPage extends StatelessWidget {
  const MedicineDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔝 TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const Icon(Icons.arrow_back_ios),

                  const Text(
                    "Meglitinides",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.more_vert),
                  )
                ],
              ),

              const SizedBox(height: 30),

              // 💊 BIG ICON
              Center(
                child: Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.yellow.shade400,
                        Colors.orange.shade300
                      ],
                    ),
                  ),
                  child: const Icon(Icons.medication,
                      size: 70, color: Colors.white),
                ),
              ),

              const SizedBox(height: 30),

              // 🗑 REMOVE BUTTON
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Remove",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 📌 TITLE
              const Text(
                "Meglitinides",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "They bind to an ATP-dependent (KATP) channel on the cell membrane of pancreatic beta cells...",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // 🍽 TAGS
              Row(
                children: [
                  _tag("Before Breakfast", Colors.orange),
                  const SizedBox(width: 10),
                  _tag("Before Dinner", Colors.green),
                ],
              ),

              const SizedBox(height: 20),

              // 📊 INFO CARDS
              Row(
                children: [
                  Expanded(child: _infoCard("Amount", "2 pill/Day")),
                  const SizedBox(width: 10),
                  Expanded(child: _infoCard("This Month", "3/31 taken")),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _infoCard("Cause", "Diabetes")),
                  const SizedBox(width: 10),
                  Expanded(child: _infoCard("Cap Size", "150 mg")),
                ],
              ),

              const Spacer(),

              // 🔘 BUTTON
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2E8B57),
                      Color(0xFF4CAF50),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "Edit Schedule",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 TAG WIDGET
  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  // 🔹 INFO CARD
  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}