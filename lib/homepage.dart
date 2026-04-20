import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'medicinecard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 1;
  List medicines = [];

  @override
  void initState() {
    super.initState();
    fetchMedicine("paracetamol");
  }

  // 🔥 API CALL
  Future<void> fetchMedicine(String name) async {
    final url =
        "https://api.fda.gov/drug/label.json?search=$name&limit=3";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        medicines = data['results'] ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // 🔥 Bottom Navigation
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.grid_view, color: Colors.blue),
            Icon(Icons.calendar_today, color: Colors.grey),

            // ➕ CENTER BUTTON
            Container(
              height: 60,
              width: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2E8B57),
                    Color(0xFF4CAF50),
                  ],
                ),
              ),
              child:
              const Icon(Icons.add, color: Colors.white, size: 30),
            ),

            Icon(Icons.list_alt, color: Colors.grey),
            Icon(Icons.person, color: Colors.grey),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView( // 🔥 FIXED
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 🔝 Header
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Your Medicines\nReminder",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications,
                          color: Colors.white),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // 📅 Clickable Date
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: _dateItem(
                          "${4 + index}",
                          ["Sat", "Sun", "Mon", "Tue", "Wed"][index],
                          selectedIndex == index,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Today",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // 🔥 API LIST FIXED
                medicines.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child:
                    CircularProgressIndicator(),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true, // 🔥 FIX
                  physics:
                  const NeverScrollableScrollPhysics(), // 🔥 FIX
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    var item = medicines[index];

                    String title =
                        item['openfda']?['brand_name']?[0] ??
                            "No Name";

                    String desc =
                        item['purpose']?[0] ??
                            "No Description";

                    return MedicineCard(
                      title: title,
                      subtitle: desc,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📅 Date Widget
  Widget _dateItem(
      String day, String week, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 60,
      decoration: BoxDecoration(
        color:
        isSelected ? Colors.pinkAccent : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(day,
              style: TextStyle(
                  fontSize: 18,
                  color: isSelected
                      ? Colors.white
                      : Colors.black)),
          Text(week,
              style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.grey)),
        ],
      ),
    );
  }
}