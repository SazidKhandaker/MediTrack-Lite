import 'package:flutter/material.dart';
import 'package:meditrack/Utils/app_text.dart' show AppText;

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  final nameController = TextEditingController();

  String selectedMeal = "After Meal";
  String? selectedTime;
  String? selectedDate;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title:Text(AppText.addMedicine(lang)),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 TITLE
            Text(
              "${ AppText.addMedicineDetails(lang)}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            // 💊 Medicine Name
            _card(
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "${AppText.medicineName(lang)}",
                  prefixIcon: const Icon(Icons.medication),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 🍽️ Meal
            _card(
              child: DropdownButtonFormField<String>(
                value: selectedMeal,
                items: [
                  DropdownMenuItem(
                      value: "Before Meal", child: Text("${AppText.beforeMeal(lang)}")),
                   DropdownMenuItem(
                      value: "After Meal", child: Text("${AppText.afterMeal(lang)}")),
                ],
                onChanged: (val) {
                  setState(() {
                    selectedMeal = val!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Instruction",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.restaurant),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ⏰ TIME
            _card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(
                  selectedTime ?? "${AppText.selectTime(lang)}",
                  style: TextStyle(
                    color: selectedTime == null
                        ? Colors.grey
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (picked != null) {
                    setState(() {
                      selectedTime = picked.format(context);
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 15),

            // 📅 DATE
            _card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  selectedDate ?? "${AppText.selectDate(lang)}",
                  style: TextStyle(
                    color: selectedDate == null
                        ? Colors.grey
                        : Theme.of(context).colorScheme.onSurface,
                  ),
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
                      selectedDate =
                      "${picked.year}-${picked.month}-${picked.day}";
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  // 🔥 validation
                  if (nameController.text.isEmpty ||
                      selectedTime == null ||
                      selectedDate == null) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppText.fillAllFields(lang))),
                    );
                    return;
                  }

                  // 🔥 HERE you will add Firebase save

                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text(AppText.saved(lang))),
                  );

                  Navigator.pop(context);
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

  // 🔥 reusable card
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          )
        ],
      ),
      child: child,
    );
  }
}