// homepage.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meditrack/bottomnavigation/profilepage.dart' show ProfilePage;
import 'package:meditrack/bottomnavigation/calendar_page.dart' show CalendarPage;
import 'medicinecard.dart';
import 'calendar_page.dart';
import 'add_page.dart';
import 'list_page.dart';
import 'profile_page.dart';

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

  // 🔥 NAVIGATION FUNCTION
  void navigateTo(int index) {
    Widget page;

    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const CalendarPage();
        break;
      case 2:
        page = const AddPage();
        break;
      case 3:
        page = const ListPage();
        break;
      case 4:
        page = const ProfilePage();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // 🔥 CLICKABLE NAV BAR
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            // HOME
            GestureDetector(
              onTap: () => navigateTo(0),
              child: const Icon(Icons.grid_view, color: Colors.blue),
            ),

            // CALENDAR
            GestureDetector(
              onTap: () => navigateTo(1),
              child: const Icon(Icons.calendar_today, color: Colors.grey),
            ),

            // ADD
            GestureDetector(
              onTap: () => navigateTo(2),
              child: Container(
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
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),

            // LIST
            GestureDetector(
              onTap: () => navigateTo(3),
              child: const Icon(Icons.list_alt, color: Colors.grey),
            ),

            // PROFILE
            GestureDetector(
              onTap: () => navigateTo(4),
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // HEADER
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
                        color: Colors.green,
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications,
                          color: Colors.white),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // DATE
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

                const SizedBox(height: 20),

                medicines.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    var item = medicines[index;

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