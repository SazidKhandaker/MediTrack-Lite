import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditrack/Utils/app_text.dart';
import 'package:meditrack/Utils/date_helper.dart';
class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {

  Stream<QuerySnapshot> getMedicines() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medicines')
        .snapshots();
  }

  Map<String, double> calculateStats(List docs) {
    if (docs.isEmpty) return {"taken": 0, "missed": 0};

    int taken = docs.where((d) {
      final data = d.data() as Map<String, dynamic>;
      return data['status'] == true;
    }).length;

    int missed = docs.length - taken;

    return {
      "taken": taken / docs.length,
      "missed": missed / docs.length,
    };
  }

  @override
  Widget build(BuildContext context) {

    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // 🔥 APP BAR
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration:  BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [Colors.black87, Colors.black]
                  : [Color(0xFF2E8B57), Color(0xFF4CAF50)],

            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              AppText.history(lang),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ?  [Colors.black, Colors.grey.shade900]
                :  [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: StreamBuilder<QuerySnapshot>(
          stream: getMedicines(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var docs = snapshot.data!.docs;
            var stats = calculateStats(docs);

            double takenPercent = stats['taken']!;
            double missedPercent = stats['missed']!;

            return Column(
              children: [

                const SizedBox(height: 20),

                // 🔥 LOGO
                Container(
                  height: MediaQuery.of(context).size.width * 0.3,
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                     color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: const Icon(Icons.local_fire_department,
                      size: 60,
                      color: Colors.orange),
                ),

                const SizedBox(height: 20),

                // 🔥 GRAPH
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${(takenPercent * 100).toInt()}%",style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035 ),),
                          Text("${(missedPercent * 100).toInt()}%",style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035 ),),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            flex: (takenPercent * 100).toInt(),
                            child: Container(
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(10)),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: (missedPercent * 100).toInt(),
                            child: Container(
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 LIST
                Expanded(
                  child: docs.isEmpty
                      ? Center(
                    child: Text(AppText.noMedicine(lang)),
                  )
                      : ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {

                      var data = docs[index];
                      final map =
                      data.data() as Map<String, dynamic>;

                      bool isTaken = map['status'] == true;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isTaken
                                ? Colors.green
                                : Colors.red,
                            width: 2,
                          ),
                        ),

                        child: Row(
                          children: [

                            CircleAvatar(
                              backgroundColor: isTaken
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              child: Icon(
                                Icons.medication,
                                color: isTaken
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [

                                  Text(map['name'] ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),


                                  Text(maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    lang == "bn"
                                        ? DateHelper.formatBanglaDate(map['date'] ?? "")
                                        : map['date'] ?? "",
                                    style:  TextStyle(
                                      color: Theme.of(context).textTheme.bodyMedium!.color),
                                  ),
                                ],
                              ),
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: IntrinsicWidth(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                      )
                                    ],
                                    color: isTaken
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isTaken
                                        ? AppText.taken(lang)
                                        : AppText.missed(lang),
                                    style: TextStyle(
                                      color: isTaken ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}