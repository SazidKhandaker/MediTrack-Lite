import 'package:flutter/material.dart';
import 'package:meditrack/Utils/app_text.dart' show AppText;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditrack/widget/notification_service.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  final nameController = TextEditingController();

  String selectedMeal = "After Meal";
  TimeOfDay? selectedTime; // 🔥 FIXED
  String? selectedDate;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.addMedicine(lang)),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            Text(
              AppText.addMedicineDetails(lang),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            /// MEDICINE NAME
            _card(
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppText.medicineName(lang),
                  prefixIcon: const Icon(Icons.medication),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// MEAL
            _card(
              child: DropdownButtonFormField<String>(
                value: selectedMeal,
                items: [
                  DropdownMenuItem(
                    value: "Before Meal",
                    child: Text(AppText.beforeMeal(lang)),
                  ),
                  DropdownMenuItem(
                    value: "After Meal",
                    child: Text(AppText.afterMeal(lang)),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    selectedMeal = val!;
                  });
                },
                decoration: InputDecoration(
                  labelText: AppText.instruction(lang),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.restaurant),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// TIME
            _card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  selectedTime == null
                      ? AppText.selectTime(lang)
                      : selectedTime!.format(context),
                ),
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (picked != null) {
                    setState(() {
                      selectedTime = picked;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 15),

            /// DATE
            _card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  selectedDate ?? AppText.selectDate(lang),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    setState(() {
                      selectedDate = formatDate(picked);
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 30),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  if (nameController.text.isEmpty ||
                      selectedTime == null ||
                      selectedDate == null) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppText.fillAllFields(lang))),
                    );
                    return;
                  }

                  final user = FirebaseAuth.instance.currentUser;

                  try {

                    /// 🔥 FIREBASE SAVE
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .collection('medicines')
                        .add({
                      "name": nameController.text,
                      "meal": selectedMeal,
                      "time": selectedTime!.format(context),
                      "date": selectedDate,
                      "createdAt": Timestamp.now(),
                      "status": false,
                    });
                    print("🔥 SAVE BUTTON CLICKED");
                    await NotificationService.cancelAll();

                    /// 🔥 NOTIFICATION (FINAL FIX)
                    int hour = selectedTime!.hour;
                    int minute = selectedTime!.minute;
                    print("🔥 BEFORE SCHEDULE");
                    await NotificationService.scheduleMedicine(
                      name: nameController.text,
                      hour: hour,
                      minute: minute,
                      beforeMin: 1,
                    );
                    print("🔥 AFTER SCHEDULE");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Reminder Set + Saved ✅")),
                    );

                    Navigator.pop(context);

                  } catch (e) {
                    print(e);
                  }

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child:  Text(
                  "${AppText.saveMedicine(lang)}",
                  style: TextStyle(fontSize: 16),
                ),

              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: child,
    );
  }

  String formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }
}