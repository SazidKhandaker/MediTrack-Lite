import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
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

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index];

              return ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(data["date"]),
                subtitle: Text(
                  "${data["steps"]} steps | ${data["distance"].toStringAsFixed(2)} km",
                ),
                trailing: Text(
                  "${data["calories"].toStringAsFixed(0)} kcal",
                ),
              );
            },
          );
        },
      ),
    );
  }
}