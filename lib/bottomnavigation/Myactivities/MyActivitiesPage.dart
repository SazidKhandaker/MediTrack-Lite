import 'package:flutter/material.dart';
import 'package:meditrack/Model/watermodel.dart';
import 'package:meditrack/Utils/app_text.dart';
import 'package:meditrack/bottomnavigation/Myactivities/stopwatch_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class MyActivitiesPage extends StatefulWidget {
  const MyActivitiesPage({super.key});

  @override
  State<MyActivitiesPage> createState() => _MyActivitiesPageState();
}

class _MyActivitiesPageState extends State<MyActivitiesPage> {

  double? goal; // 🔥 nullable (user set করবে)
  double current = 0;

  int selectedIndex = 0;
  final List<int> amounts = [250, 500, 750, 1000];

  double get progress {
    if (goal == null || goal == 0) return 0;
    return (current / goal!).clamp(0, 1);
  }

  void addWater(int ml) async {
    if (goal == null) return;

    setState(() {
      current += ml / 1000;

      if (current > goal!) {
        current = goal!;
      }
    });

    await saveWaterData(); // 🔥 important
  }

  Color getStatusColor() {
    if (progress < 0.4) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }
  String getTodayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }
  @override
  void initState() {
    super.initState();
    loadWaterData();
  }
  Future<void> loadWaterData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('water')
        .doc(getTodayKey())
        .get();

    if (doc.exists) {
      setState(() {
        goal = (doc['goal'] as num?)?.toDouble();
        current = (doc['current'] as num?)?.toDouble() ?? 0;
      });
    }
  }
  Future<void> saveWaterData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('water')
        .doc(getTodayKey())
        .set({
      "goal": goal,
      "current": current,
    }, SetOptions(merge: true));
  }
  Widget build(BuildContext context) {

    final lang = Localizations.localeOf(context).languageCode;
    final state = getWaterState(lang);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(lang == "bn" ? "আমার কার্যক্রম" : "My Activities"),
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [

                // 🔥 HEADER
                _buildHeader(state),

                const SizedBox(height: 15),

                // 🔥 GOAL SECTION
                goal == null
                    ? _buildSelectGoalUI(lang)
                    : _buildGoalProgressUI(lang),

                const SizedBox(height: 15),

                // 🔥 SIP TEXT
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    lang == "bn" ? "পানির পরিমাণ নির্বাচন করুন" : "Choose Your Sip",
                  ),
                ),

                const SizedBox(height: 10),

                // 🔥 SIP BUTTONS
                Row(
                  children: List.generate(amounts.length, (index) {
                    bool isSelected = selectedIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          addWater(amounts[index]);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green.shade100
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.local_drink),
                              const SizedBox(height: 6),
                              Text("${amounts[index]} ml"),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // 🔥 WALK BUTTON
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StopwatchPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions_walk),
                  label: Text(lang == "bn" ? "হাঁটা শুরু করুন" : "Start Walking"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 HEADER UI
  Widget _buildHeader(WaterState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            state.color.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: state.color,
            ),
            child: Text(
              state.label,
              style: const TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(height: 15),

          Image.asset(state.image, height: 140),

          const SizedBox(height: 10),

          Text(
            state.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: state.color,
            ),
          ),

          const SizedBox(height: 5),

          Text(state.subtitle),

          const SizedBox(height: 10),

          Column(
            children: state.tips.map<Widget>((tip) {
              return ListTile(
                leading: Icon(tip["icon"], color: state.color),
                title: Text(tip["text"]),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 🔥 SELECT GOAL UI
  Widget _buildSelectGoalUI(String lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop),
              const SizedBox(width: 8),
              Text(
                lang == "bn"
                    ? "আজকের লক্ষ্য নির্ধারণ করুন"
                    : "Select Your Today’s Target",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Wrap(
            spacing: 10,
            children: [2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0].map((value) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:  goal == value
                      ? Colors.blue
                      : Colors.blue.shade50,
                  foregroundColor: goal == value
                      ? Colors.white
                      : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: () async {
                  setState(() {
                    goal = value;
                    current = 0;
                  });

                  await saveWaterData(); // 🔥 add this
                },
                child: Text("${value} L"),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // 🔥 GOAL UI
  Widget _buildGoalProgressUI(String lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lang == "bn" ? "দৈনিক লক্ষ্য" : "Daily Goal"),
              TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(lang == "bn" ? "লক্ষ্য পরিবর্তন?" : "Change Goal?"),
                        content: Text(lang == "bn"
                            ? "আপনি কি নতুন লক্ষ্য নির্ধারণ করতে চান?"
                            : "Do you want to set a new goal?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(lang == "bn" ? "না" : "Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                goal = null;
                              });
                              Navigator.pop(context);
                            },
                            child: Text(lang == "bn" ? "হ্যাঁ" : "Yes"),
                          ),
                        ],
                      ),
                    );
                  },
                child: Text(lang == "bn" ? "পরিবর্তন" : "Change"),
              )
            ],
          ),

          Text("${goal!.toStringAsFixed(1)} L"),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: progress,
            color: getStatusColor(),
          ),

          const SizedBox(height: 6),

          Text("${current.toStringAsFixed(1)} L"),
        ],
      ),
    );
  }

  // 🔥 STATE LOGIC
  WaterState getWaterState(String lang) {
    if (progress < 0.4) {
      return WaterState(
        label: lang == "bn" ? "অপর্যাপ্ত" : "UNHEALTHY",
        image: "assets/images/unhealthy.png",
        color: Colors.red,
        title: lang == "bn" ? "আরও পানি পান করুন" : "Drink More Water!",
        subtitle: lang == "bn"
            ? "আপনার শরীরে পানি কম আছে"
            : "Your body needs more water.",
        tips: [
          {"icon": Icons.battery_alert, "text": lang == "bn" ? "কম শক্তি" : "Low Energy"},
          {"icon": Icons.psychology, "text": lang == "bn" ? "মাথা ব্যথা" : "Headache"},
          {"icon": Icons.spa, "text": lang == "bn" ? "শুষ্ক ত্বক" : "Dry Skin"},
        ],
      );
    } else if (progress < 0.7) {
      return WaterState(
        label: lang == "bn" ? "স্বাভাবিক" : "NORMAL",
        image: "assets/images/normal.png",
        color: Colors.orange,
        title: lang == "bn" ? "চালিয়ে যান" : "Good Job!",
        subtitle: lang == "bn"
            ? "আপনি ঠিক পথে আছেন"
            : "You are on the right track.",
        tips: [
          {"icon": Icons.verified, "text": lang == "bn" ? "ভালো ভারসাম্য" : "Good Balance"},
          {"icon": Icons.directions_run, "text": lang == "bn" ? "ভালো ফোকাস" : "Better Focus"},
          {"icon": Icons.emoji_emotions, "text": lang == "bn" ? "ভালো লাগছে" : "Feeling Good"},
        ],
      );
    } else {
      return WaterState(
        label: lang == "bn" ? "ভালো" : "HEALTHY",
        image: "assets/images/healthy.png",
        color: Colors.green,
        title: lang == "bn" ? "দারুণ!" : "Great!",
        subtitle: lang == "bn"
            ? "আপনি সম্পূর্ণ হাইড্রেটেড"
            : "You are well hydrated.",
        tips: [
          {"icon": Icons.water_drop, "text": lang == "bn" ? "উচ্চ শক্তি" : "High Energy"},
          {"icon": Icons.shield, "text": lang == "bn" ? "শক্তিশালী রোগ প্রতিরোধ" : "Strong Immunity"},
          {"icon": Icons.favorite, "text": lang == "bn" ? "সুস্থ শরীর" : "Healthy Body"},
        ],
      );
    }
  }
}