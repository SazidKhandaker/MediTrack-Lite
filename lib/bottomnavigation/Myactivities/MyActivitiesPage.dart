import 'package:flutter/material.dart';
import 'package:meditrack/Model/watermodel.dart' show WaterState;
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
    final state = getWaterState(lang);
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
                state.color.withOpacity(0.1),
                Colors.white,
              ],
            ),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),

          child: Column(
            children: [

              // 🔥 LABEL
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [state.color, state.color.withOpacity(0.7)],
                  ),
                ),
                child: Text(
                  state.label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 15),

              // 💧 IMAGE
              Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state.color.withOpacity(0.1),
                ),
                child: Center(
                  child: Image.asset(state.image, height: 200,fit: BoxFit.cover,),
                ),
              ),

              const SizedBox(height: 15),

              // 🔥 TITLE
              Text(
                state.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: state.color,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                state.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 15),

              // 📦 TIPS
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: state.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: List.generate(state.tips.length, (i) {
                    final tip = state.tips[i];
                    return Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: state.color.withOpacity(0.2),
                              child: Icon(tip["icon"], color: state.color),
                            ),
                            const SizedBox(width: 10),
                            Text(tip["text"]),
                          ],
                        ),
                        if (i != state.tips.length - 1) const Divider(),
                      ],
                    );
                  }),
                ),
              ),
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