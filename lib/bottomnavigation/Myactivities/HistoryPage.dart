import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditrack/utils/app_text.dart';
import 'package:meditrack/utils/date_helper.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    /// 🎨 Gradient list (mixed colors)
    final List<List<Color>> cardGradients = [
      [Colors.orange.shade300, Colors.deepOrange],
      [Colors.blue.shade300, Colors.blueAccent],
      [Colors.green.shade300, Colors.teal],
      [Colors.purple.shade300, Colors.deepPurple],
      [Colors.pink.shade300, Colors.redAccent],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.history(lang)),
        centerTitle: true,
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("activity")
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                lang == "bn" ? "কোনো ডাটা নেই" : "No history yet",
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {

              var data = docs[index];

              double distance = data["distance"] ?? 0;
              double calories = data["calories"] ?? 0;

              /// 🔥 dynamic gradient
              final gradient =
              cardGradients[index % cardGradients.length];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                      gradient[0].withOpacity(0.4),
                      gradient[1].withOpacity(0.4)
                    ]
                        : gradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[1].withOpacity(0.3),
                      blurRadius: 10,
                    )
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 📅 DATE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang == "bn"
                              ? DateHelper.formatBanglaDate(data["date"])
                              : data["date"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Icon(Icons.calendar_month,
                            color: Colors.white),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// 📊 DATA ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        _item(
                          icon: Icons.directions_walk,
                          value: "${data["steps"]}",
                          label: lang == 'bn' ? "স্টেপ" : "steps",
                        ),

                        _item(
                          icon: Icons.map,
                          value: "${distance.toStringAsFixed(2)}",
                          label: "km",
                        ),

                        _item(
                          icon: Icons.local_fire_department,
                          value: "${calories.toStringAsFixed(0)}",
                          label: "kcal",
                        ),

                        _item(
                          icon: Icons.timer,
                          value: data["formatted_time"] ?? "00:00",
                          label: lang == "bn" ? "সময়" : "time",
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 🔥 ITEM DESIGN
  Widget _item({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}