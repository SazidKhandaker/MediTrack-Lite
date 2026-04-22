import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meditrack/bottomnavigation/profile/profilepage.dart' show ProfilePage;
import 'package:meditrack/bottomnavigation/calendar_page.dart' show CalendarPage;
import 'bottomnavigation/AddPage.dart' show AddPage;
import 'bottomnavigation/Listpage.dart' show ListPage;
import 'package:firebase_auth/firebase_auth.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 1;
  List medicines = [];

  Map<int, bool> takenStatus = {}; // 🔥 taken/missed

  @override
  void initState() {
    super.initState();
    fetchMedicine("paracetamol");
  }

  Future<void> fetchMedicine(String name) async {
    final url =
        "https://api.fda.gov/drug/label.json?search=$name&limit=5";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        medicines = data['results'] ?? [];
      });
    }
  }

  // 🔥 progress
  double getProgress() {
    if (medicines.isEmpty) return 0;
    int taken = takenStatus.values.where((e) => e).length;
    return taken / medicines.length;
  }

  // 🔥 NAVIGATION
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // 🔥 NAV BAR (unchanged)
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

            GestureDetector(
              onTap: () => navigateTo(0),
              child: const Icon(Icons.grid_view, color: Colors.blue),
            ),

            GestureDetector(
              onTap: () => navigateTo(1),
              child: const Icon(Icons.calendar_today, color: Colors.grey),
            ),

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

            GestureDetector(
              onTap: () => navigateTo(3),
              child: const Icon(Icons.list_alt, color: Colors.grey),
            ),

    GestureDetector(
    onTap: () async {
    await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ProfilePage()),
    );

    setState(() {}); // 🔥 refresh homepage
    },
    child: Builder(
    builder: (context) {
    final user = FirebaseAuth.instance.currentUser;

    return CircleAvatar(
    radius: 20,
    backgroundColor: Colors.grey.shade300,

    backgroundImage: user?.photoURL != null
    ? NetworkImage(
    user!.photoURL! +
    "?t=${DateTime.now().millisecondsSinceEpoch}",
    )
        : null,

    child: user?.photoURL == null
    ? const Icon(Icons.person, color: Colors.grey)
        : null,
    );
    },
    ),
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

                // 🔝 HEADER
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Medicines\nReminder",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                    Row(
                      children: [

                        // 🔔 Notification
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications, color: Colors.white),
                        ),

                        const SizedBox(width: 10),

                        // 👤 Profile Avatar
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );

              setState(() {}); // 🔥 extra safety
            },
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(), // 🔥 FIXED
              builder: (context, snapshot) {

                final user = snapshot.data;

                return CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,

                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(
                    user!.photoURL!)
                      : null,

                  child: user?.photoURL == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                );
              },
            ),
          ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // 📅 DATE (real-time)
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {

                      DateTime date =
                      DateTime.now().add(Duration(days: index - 1));

                      String day = date.day.toString();

                      String weekDay = [
                        "Mon","Tue","Wed","Thu","Fri","Sat","Sun"
                      ][date.weekday - 1];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: _dateItem(
                          day,
                          weekDay,
                          selectedIndex == index,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // 🔥 PROGRESS
                const Text("Today's Progress",
                    style: TextStyle(fontWeight: FontWeight.bold)),

                const SizedBox(height: 6),

                LinearProgressIndicator(
                  value: getProgress(),
                  color: Colors.green,
                  backgroundColor: Colors.grey.shade300,
                ),

                const SizedBox(height: 20),

                // 🔥 MEDICINE LIST
                medicines.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {

                    var item = medicines[index];

                    String title =
                        item['openfda']?['brand_name']?[0] ??
                            "No Name";

                    String desc =
                        item['purpose']?[0] ??
                            "Take after meal";

                    bool isTaken =
                        takenStatus[index] ?? false;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                          ),
                        ],
                      ),


                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),

                          Text(desc,
                              style:
                              const TextStyle(color: Colors.grey)),

                          const SizedBox(height: 8),

                          const Text(
                            "Next dose: 8:00 PM",
                            style:
                            TextStyle(color: Colors.orange),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [

                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    takenStatus[index] = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.green),
                                child: const Text("Taken"),
                              ),

                              const SizedBox(width: 10),

                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    takenStatus[index] = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.red),
                                child: const Text("Missed"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          Text(
                            isTaken
                                ? "✔ Taken"
                                : "❌ Not taken",
                            style: TextStyle(
                                color: isTaken
                                    ? Colors.green
                                    : Colors.red),
                          )
                        ],
                      ),
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