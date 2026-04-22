import 'package:flutter/material.dart';
import 'package:meditrack/Model/medicinemodel.dart' show Medicine;

class AddPage extends StatelessWidget {
   AddPage({super.key});
List<Medicine> globalMedicines=[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Medicine")),
      body: Center(child: Text("Add Page")),
    );
  }
}