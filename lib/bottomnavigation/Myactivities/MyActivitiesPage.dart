import 'package:flutter/material.dart';
import 'package:meditrack/Utils/app_text.dart';
import 'package:meditrack/bottomnavigation/Myactivities/stopwatch_page.dart' show StopwatchPage;


class MyActivitiesPage extends StatefulWidget {
  const MyActivitiesPage({super.key});

  @override
  State<MyActivitiesPage> createState() => _MyActivitiesPageState();
}

class _MyActivitiesPageState extends State<MyActivitiesPage> {

  double goal = 2.5; // liter
  double current = 0;

  int selectedIndex = 0;

  final List<int> amounts = [250, 500, 750, 1000];

  double get progress => (current / goal).clamp(0, 1);

  void addWater(int ml) {
    setState(() {
      current += ml / 1000;
    });
  }

  String getStatus(String lang) {
    if (progress < 0.4) return AppText.unhealthy(lang);
    if (progress < 0.7) return AppText.normal(lang);
    return AppText.healthy(lang);
  }

  Color getStatusColor() {
    if (progress < 0.4) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }
  String getHeaderImage() {
    if (progress < 0.4) {
      return "assets/images/unhealthy.png";
    } else if (progress < 0.7) {
      return "assets/images/normal.png";
    } else {
      return "assets/images/healthy.png";
    }
  }

  @override
  Widget build(BuildContext context) {

    final lang = Localizations.localeOf(context).languageCode;

    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text(AppText.activities(lang)),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              // 🔥 HEADER IMAGE SECTION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade50,
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                ),

                child: Column(
                  children: [

                    // 🔴 TOP TAG
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                        ),
                      ),
                      child: const Text(
                        "UNHEALTHY",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 💧 IMAGE WITH BACKGROUND
                    Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/images/unhealthy.png",
                          height: 120,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔥 TITLE
                    const Text(
                      "Drink More Water!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Your body needs more water.\nStay hydrated and feel better.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 15),

                    // 📦 INFO BOX
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [

                          _infoRow(Icons.battery_alert, "Low Energy", Colors.red),
                          const Divider(),
                          _infoRow(Icons.psychology, "Headache", Colors.red),
                          const Divider(),
                          _infoRow(Icons.spa, "Dry Skin", Colors.red),

                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 15),
              // 🔥 DAILY GOAL CARD
              Container(
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
                        Text(AppText.dailyGoal(lang),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {},
                          child: Text(AppText.change(lang)),
                        )
                      ],
                    ),

                    Text("${goal.toStringAsFixed(1)} ${AppText.liter(lang)}"),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: progress,
                      color: getStatusColor(),
                      backgroundColor: Colors.grey.shade300,
                    ),

                    const SizedBox(height: 6),

                    Text("${current.toStringAsFixed(1)} ${AppText.liter(lang)}"),

                    const SizedBox(height: 8),

                    Text(
                      getStatus(lang),
                      style: TextStyle(
                        color: getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 🔥 SIP SELECTOR
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppText.chooseSip(lang)),
              ),

              const SizedBox(height: 10),

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

              // 🔥 WALKING BUTTON
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
                label: Text(AppText.startWalking(lang)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

            ],
          ),
        ),
      ),
    ));
  }
  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 10),
        Text(text),
      ],
    );
  }
}