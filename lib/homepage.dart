import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditrack/Utils/app_text.dart' show AppText;

import 'package:meditrack/bottomnavigation/profile/profilepage.dart';
import 'package:meditrack/bottomnavigation/calendar_page.dart';
import 'bottomnavigation/AddPage.dart';
import 'bottomnavigation/Listpage.dart';
 // 🔥 language file

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  DateTime selectedDate = DateTime.now();
  Map<int, bool> takenStatus = {};

  // 🔥 Firebase stream
  Stream<QuerySnapshot> getMedicines() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medicines')
        .snapshots();
  }

  // 🔥 progress calc
  double getProgress(List docs) {
    if (docs.isEmpty) return 0;
    int taken = takenStatus.values.where((e) => e).length;
    return taken / docs.length;
  }

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
  int centerIndex = 15;
  @override
  Widget build(BuildContext context) {

    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // 🔻 Bottom nav SAME
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
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
                    colors: [Color(0xFF2E8B57), Color(0xFF4CAF50)],
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),

            GestureDetector(
              onTap: () => navigateTo(3),
              child: const Icon(Icons.list_alt, color: Colors.grey),
            ),

            // 🔥 PROFILE CLICK FIXED
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
                setState(() {});
              },
              child: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.userChanges(),
                builder: (context, snapshot) {

                  final user = snapshot.data;

                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL! +
                        "?t=${DateTime.now().millisecondsSinceEpoch}")
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
                    AppText.reminder(lang),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  Row(
                    children: [

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications,
                            color: Colors.white),
                      ),

                      const SizedBox(width: 10),

                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfilePage()),
                          );
                          setState(() {});
                        },
                        child: StreamBuilder<User?>(
                          stream:
                          FirebaseAuth.instance.userChanges(),
                          builder: (context, snapshot) {

                            final user = snapshot.data;

                            return CircleAvatar(
                              radius: 20,
                              backgroundColor:
                              Colors.grey.shade300,
                              backgroundImage:
                              user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!)
                                  : null,
                              child: user?.photoURL == null
                                  ? const Icon(Icons.person,
                                  color: Colors.grey)
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

              // 📅 FULL MONTH CALENDAR
              SizedBox(
                height: 80,
                child: ListView.builder(
                  controller: ScrollController(
                    initialScrollOffset: centerIndex * 70, // 🔥 auto center
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: 30,

                  itemBuilder: (context, index) {

                    DateTime date =
                    DateTime.now().add(Duration(days: index - centerIndex));

                    bool isSelected =
                        date.year == selectedDate.year &&
                            date.month == selectedDate.month &&
                            date.day == selectedDate.day;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      child: _dateItem(
                        "${date.day}",
                        ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                        [date.weekday % 7],
                        isSelected,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              // 🔥 PROGRESS
              Text(AppText.progress(lang),
                  style: const TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 6),

              // 🔥 FIREBASE LIST + PROGRESS
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getMedicines(),
                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var docs = snapshot.data!.docs;

                    var filtered = docs.where((doc) {
                      return doc['date'] ==
                          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                    }).toList();

                    return Column(
                      children: [

                        LinearProgressIndicator(
                          value: getProgress(filtered),
                          color: Colors.green,
                          backgroundColor: Colors.grey.shade300,
                        ),

                        const SizedBox(height: 20),

                        // ❌ EMPTY UI
                        if (filtered.isEmpty)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.medication_outlined,
                                      size: 80,
                                      color: Colors.grey),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppText.noMedicine(lang),
                                    style: const TextStyle(
                                        fontWeight:
                                        FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          )

                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {

                                var data = filtered[index];

                                bool isTaken =
                                    takenStatus[index] ?? false;

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.all(16),

                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFF1E293B) // 🔥 dark card color
                                        : Colors.white,

                                    borderRadius: BorderRadius.circular(18),

                                    // 🔥 THICK BORDER
                                    border: Border.all(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.greenAccent // dark mode border
                                          : Colors.green,      // light mode border
                                      width: 2.2,
                                    ),

                                    // 🔥 SHADOW
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),

                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [

                                      Text(data['name'],
                                          style: const TextStyle(
                                              fontWeight:
                                              FontWeight.bold)),

                                      Text(AppText.meal(lang, data['meal'])),

                                      Text("${AppText.nextDose(lang)} ${data['time']}",
                                          style: const TextStyle(
                                              color: Colors.orange)),

                                      const SizedBox(height: 10),

                                      Row(
                                        children: [

                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                takenStatus[index] = true;
                                              });
                                            },
                                            child: Text(AppText.taken(lang)),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green),
                                          ),

                                          const SizedBox(width: 10),

                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                takenStatus[index] = false;
                                              });
                                            },
                                            child: Text(AppText.missed(lang)),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
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
                                              : Colors.red,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateItem(String day, String week, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 60,
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day,
              style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? Colors.white : Colors.black)),
          Text(week,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey)),
      Text(
        "${_getMonthName(selectedDate.month)} ",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.green[200]
        ),)
        ],
      ),
    );
  }
  String _getMonthName(int month) {
    const months = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    return months[month - 1];
  }
}