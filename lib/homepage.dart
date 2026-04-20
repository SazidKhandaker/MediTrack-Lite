import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // 🔻 Bottom Navigation
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.grid_view, color: Colors.blue),
            Icon(Icons.calendar_today, color: Colors.grey),
            Container(
              height: 55,
              width: 55,
              decoration: const BoxDecoration(
                color: Color(0xFF2E8B57),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            Icon(Icons.list_alt, color: Colors.grey),
            Icon(Icons.person, color: Colors.grey),
          ],
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔝 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Your Medicines\nReminder",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications, color: Colors.white),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // 📅 Date Selector
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _dateItem("4", "Sat", false),
                    _dateItem("5", "Sun", true),
                    _dateItem("6", "Mon", false),
                    _dateItem("7", "Tue", false),
                    _dateItem("8", "Wed", false),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 🔘 Tabs
              Row(
                children: const [
                  Text("Today",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                  SizedBox(width: 20),
                  Text("Week", style: TextStyle(color: Colors.grey)),
                  SizedBox(width: 20),
                  Text("Month", style: TextStyle(color: Colors.grey)),
                ],
              ),

              const SizedBox(height: 20),

              // 📋 Medicine List
              Expanded(
                child: ListView(
                  children: const [
                    MedicineCard(
                      title: "Paracetamol XL2",
                      subtitle: "150mg, 1 capsule",
                    ),
                    MedicineCard(
                      title: "DPP-4 inhibitors",
                      subtitle: "150mg, 1 capsule",
                    ),
                    MedicineCard(
                      title: "Meglitinides",
                      subtitle: "150mg, 1 capsule",
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 📅 Date Widget
  Widget _dateItem(String day, String week, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 60,
      decoration: BoxDecoration(
        color: isSelected ? Colors.pinkAccent : Colors.white,
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
        ],
      ),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const MedicineCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.medication, size: 40, color: Colors.orange),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _chip("After Breakfast", Colors.green.shade100),
                    const SizedBox(width: 6),
                    _chip("After Dinner", Colors.orange.shade100),
                  ],
                )
              ],
            ),
          ),

          const Icon(Icons.more_vert)
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }
}