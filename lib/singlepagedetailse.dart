import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditrack/utils/app_text.dart'; // 🔥 important

class MedicineDetailPage extends StatelessWidget {
  final DocumentSnapshot data;

  const MedicineDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    final map = data.data() as Map<String, dynamic>? ?? {};
    final lang = Localizations.localeOf(context).languageCode;

    String name = map['name'] ?? "Medicine";
    String time = map['time'] ?? "--:--";

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔝 TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),

                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),

                  const Icon(Icons.more_vert),
                ],
              ),

              const SizedBox(height: 30),

              // 💊 IMAGE
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.orange.shade100,
                  child: Image.asset("assets/images/medicine.png"),
                ),
              ),

              const SizedBox(height: 30),

              // 🗑 DELETE
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () async {

                    bool? confirm = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(AppText.remove(lang)),
                        content:lang=='bn'? Text("আপনি কি নিশ্চিত?")  :Text("Are you sure?") ,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("${AppText.cancel(lang)}"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(AppText.remove(lang)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final user = FirebaseAuth.instance.currentUser;

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .collection('medicines')
                          .doc(data.id)
                          .delete();

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppText.saved(lang)),
                        ),
                      );
                    }
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppText.remove(lang),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              Text(AppText.description(lang),
                  style: const TextStyle(color: Colors.grey)),

              const SizedBox(height: 20),

              Row(
                children: [
                  _tag(AppText.meal(lang, map['meal']), Colors.orange),
                  const SizedBox(width: 10),
                  _tag(time, Colors.green),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _infoCard(
                      AppText.timeLabel(lang), time)),
                  const SizedBox(width: 10),
                  Expanded(child: _infoCard(
                      AppText.statusLabel(lang),
                      map['status'] == true
                          ? AppText.takenStatus(lang)
                          : AppText.notTakenStatus(lang))),
                ],
              ),

              const Spacer(),

              // 🔥 EDIT BUTTON
              GestureDetector(
                onTap: () => _showEditSheet(context),

                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      AppText.editSchedule(lang),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 BEAUTIFUL EDIT SHEET
  void _showEditSheet(BuildContext context) {

    final map = data.data() as Map<String, dynamic>;
    final lang = Localizations.localeOf(context).languageCode;

    TextEditingController nameController =
    TextEditingController(text: map['name']);

    String selectedMeal = map['meal'];
    String selectedTime = map['time'];
    String selectedDate = map['date'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB), // 🔥 soft background
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
          
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 15,
              ),
          
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
          
                    // 🔘 HANDLE
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
          
                    const SizedBox(height: 15),
          
                    // 🔥 TITLE
                    Text(
                      AppText.editSchedule(lang),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
          
                    const SizedBox(height: 20),
          
                    // 💊 NAME FIELD
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: AppText.medicineName(lang),
                        prefixIcon: const Icon(
                          Icons.medication,
                          color: Color(0xFF2E7D32), // green
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
          
                    const SizedBox(height: 15),
          
                    // 🍽 MEAL DROPDOWN
                    DropdownButtonFormField<String>(
                      value: selectedMeal,
                      items: [
                        DropdownMenuItem(
                          value: "Before Meal",
                          child: Text(AppText.beforeMeal(lang)),
                        ),
                        DropdownMenuItem(
                          value: "After Meal",
                          child: Text(AppText.afterMeal(lang),style: TextStyle(color: Colors.black),),
                        ),
                      ],
                      onChanged: (val) => selectedMeal = val!,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.restaurant,
                          color: Color(0xFFF57C00), // orange
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
          
                    const SizedBox(height: 15),
          
                    // ⏰ TIME
                    ListTile(
                      tileColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: const Icon(
                        Icons.access_time,
                        color: Color(0xFF1976D2), // blue
                      ),
                      title: Text(
                        selectedTime,
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(AppText.selectTime(lang)),
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          selectedTime = picked.format(context);
                        }
                      },
                    ),
          
                    const SizedBox(height: 10),
          
                    // 📅 DATE
                    ListTile(
                      tileColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFD32F2F), // red
                      ),
                      title: Text(
                        selectedDate,
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(AppText.selectDate(lang)),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
          
                        if (picked != null) {
                          selectedDate =
                          "${picked.year}-${picked.month}-${picked.day}";
                        }
                      },
                    ),
          
                    const SizedBox(height: 20),
          
                    // 🔥 BUTTON ROW
                    Row(
                      children: [
          
                        // ❌ CANCEL
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              cancel(lang),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
          
                        const SizedBox(width: 10),
          
                        // ✅ UPDATE
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
          
                              final user = FirebaseAuth.instance.currentUser;
          
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user!.uid)
                                  .collection('medicines')
                                  .doc(data.id)
                                  .update({
                                "name": nameController.text,
                                "meal": selectedMeal,
                                "time": selectedTime,
                                "date": selectedDate,
                              });
          
                              Navigator.pop(context);
                              Navigator.pop(context);
          
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    lang == 'bn'
                                        ? "আপডেট সফল হয়েছে"
                                        : "Updated successfully",
                                  ),
                                ),
                              );
                            },
          
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  AppText.save(lang),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color)),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  static String cancel(String lang) {
    return lang == 'bn' ? "বাতিল" : "Cancel";
  }
}