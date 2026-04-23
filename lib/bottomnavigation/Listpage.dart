import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // 🔥 percentage calculation
  Map<String, double> calculateStats(List docs) {
    if (docs.isEmpty) return {"taken": 0, "missed": 0};

    int taken = docs.where((d) {
      final data = d.data() as Map<String, dynamic>;
      return data['status'] == true; // 🔥 safe (null হলে false)
    }).length;

    int missed = docs.length - taken;

    return {
      "taken": taken / docs.length,
      "missed": missed / docs.length,
    };
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFF1F8E9),
            ],
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

                // 🔥 LOGO SECTION
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
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

                // 🔥 GRAPH SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${(takenPercent * 100).toInt()}%",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),

                          Text("${(missedPercent * 100).toInt()}%",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 🔥 progress bar
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
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {

                      var data = docs[index];

                      final map = data.data() as Map<String, dynamic>;
                      bool isTaken = map['status'] == true;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),

                          border: Border.all(
                            color: isTaken ? Colors.green : Colors.red,
                            width: 2,
                          ),
                        ),

                        child: Row(
                          children: [

                            // 🔥 LEFT ICON
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

                            // 🔥 NAME + DATE
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [

                                  Text(data['name'],
                                      style: const TextStyle(
                                          fontWeight:
                                          FontWeight.bold)),

                                  Text(data['date'],
                                      style: const TextStyle(
                                          color: Colors.grey)),
                                ],
                              ),
                            ),

                            // 🔥 STATUS
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isTaken
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: Text(
                                isTaken ? "Taken" : "Missed",
                                style: TextStyle(
                                  color: isTaken
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
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