import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditrack/utils/app_text.dart';
import 'package:meditrack/utils/date_helper.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  /// 🔥 TIME FORMAT
  String formatDuration(int totalSeconds) {
    int m = totalSeconds ~/ 60;
    int s = totalSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    /// 🎨 gradient colors
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("activity")
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                lang == "bn" ? "কোনো ডাটা নেই" : "No history yet",
              ),
            );
          }

          final docs = snapshot.data!.docs;

          /// 🔥 GROUP + SUM
          Map<String, Map<String, dynamic>> groupedData = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final String date = data["date"] ?? "unknown";

            if (!groupedData.containsKey(date)) {
              groupedData[date] = {
                "steps": 0,
                "distance": 0.0,
                "calories": 0.0,
                "time": 0,
              };
            }

            groupedData[date]!["steps"] += (data["steps"] ?? 0) as int;
            groupedData[date]!["distance"] += (data["distance"] ?? 0).toDouble();
            groupedData[date]!["calories"] += (data["calories"] ?? 0).toDouble();
            groupedData[date]!["time"] += (data["time"] ?? 0) as int;
          }

          final groupedList = groupedData.entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: groupedList.length,
            itemBuilder: (context, index) {

              final entry = groupedList[index];
              final date = entry.key;
              final data = entry.value;

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
                      children: [

                        /// 📅 DATE (responsive)
                        Expanded(
                          child: Text(
                            lang == "bn"
                                ? DateHelper.formatBanglaDate(date)
                                : date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.035,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        /// 📅 ICON
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// 📊 DATA
                    /// 📊 DATA (RESPONSIVE + MULTI LANGUAGE)
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 10,
                      children: [

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.21,
                          child: _item(
                            icon: Icons.directions_walk,
                            value: "${data["steps"]}",
                            label: lang == 'bn' ? "স্টেপ" : "Steps",

                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.21,
                          child: _item(
                            icon: Icons.map,
                            value: "${(data["distance"] ?? 0).toDouble().toStringAsFixed(2)}",
                            label: lang == 'bn' ? "কিমি" : "km",
                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.21,
                          child: _item(
                            icon: Icons.local_fire_department,
                            value: "${(data["calories"] ?? 0).toDouble().toStringAsFixed(0)}",
                            label: lang == 'bn' ? "ক্যালরি" : "kcal",
                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.21,
                          child: _item(
                            icon: Icons.timer,
                            value: formatDuration(data["time"] ?? 0),
                            label: lang == "bn" ? "সময়" : "Time",
                          ),
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

  /// 🔥 ITEM UI
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}