import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    nameController.text = user?.displayName ?? "";
  }

  Future<void> updateProfile() async {

    // 🔥 Update Name
    await user!.updateDisplayName(nameController.text);

    // 🔥 Update Password
    if (passwordController.text.isNotEmpty) {
      await user!.updatePassword(passwordController.text);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: passwordController,
              decoration:
              const InputDecoration(labelText: "New Password"),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: updateProfile,
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}