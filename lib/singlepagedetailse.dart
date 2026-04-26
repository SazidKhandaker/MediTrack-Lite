import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineDetailPage extends StatelessWidget {
  final DocumentSnapshot data;

  const MedicineDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    final map = data.data() as Map<String, dynamic>? ?? {};

    // 🌐 Language detect
    final lang = Localizations.localeOf(context).languageCode;

    String mealText = map['meal'] ?? "";
    String name = map['name'] ?? "Medicine";
    String time = map['time'] ?? "--:--";

    // 🇧🇩 Bangla support
    String getMealText() {
      if (lang == "bn") {
        if (mealText == "Before Meal") return "খাবারের আগে";
        if (mealText == "After Meal") return "খাবারের পরে";
      }
      return mealText;
    }

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

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios),
                  ),

                  Text(
                    name,
                    style: const TextStyle(
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

              // 💊 IMAGE
              Center(
                child: Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.yellow.shade400,
                        Colors.orange.shade300,
                      ],
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/medicine.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 🗑 REMOVE BUTTON
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    lang == "bn" ? "ডিলিট" : "Remove",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 📌 TITLE
              Text(
                name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                lang == "bn"
                    ? "ওষুধের বিস্তারিত তথ্য"
                    : "Medicine details",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // 🍽 TAGS
              Row(
                children: [
                  _tag(getMealText(), Colors.orange),
                  const SizedBox(width: 10),
                  _tag(time, Colors.green),
                ],
              ),

              const SizedBox(height: 20),

              // 📊 INFO
              Row(
                children: [
                  Expanded(child: _infoCard(
                      lang == "bn" ? "সময়" : "Time",
                      time)),
                  const SizedBox(width: 10),
                  Expanded(child: _infoCard(
                      lang == "bn" ? "স্ট্যাটাস" : "Status",
                      map['status'] == true
                          ? (lang == "bn" ? "নেওয়া হয়েছে" : "Taken")
                          : (lang == "bn" ? "নেওয়া হয়নি" : "Not Taken")
                  )),
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
                child: Center(
                  child: Text(
                    lang == "bn" ? "সময় পরিবর্তন" : "Edit Schedule",
                    style: const TextStyle(
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