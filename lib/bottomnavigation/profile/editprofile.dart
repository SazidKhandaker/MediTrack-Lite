import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditrack/bottomnavigation/profile/imageuplaoded.dart' show uploadToCloudinary;
import 'package:meditrack/main.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {


  final nameController = TextEditingController();
  final aboutController = TextEditingController();
  User? user;
  @override
  void initState() {
    super.initState();
    nameController.text = user?.displayName ?? "";
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Your Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔥 PROFILE IMAGE
            GestureDetector(    onTap: () async {
              String? url = await uploadToCloudinary();

              if (url != null) {
                setState(() {
                  user = FirebaseAuth.instance.currentUser;
                });
              }
            },
              child: CircleAvatar(
                radius: 45,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Update Profile Picture",
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 CARD CONTAINER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                    )
                ],
              ),
              child: Column(
                children: [

                  // 👤 NAME
                  _buildField(
                    label: "Full Name",
                    controller: nameController,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 15),

                  // 📧 EMAIL (readonly)
                  _buildField(
                    label: "Email Address",
                    initial: user?.email ?? "",
                    readOnly: true,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 15),

                  // 📝 ABOUT
                  _buildField(
                    label: "About Me",
                    controller: aboutController,
                    maxLines: 3,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF2F9E5B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  await user?.updateDisplayName(nameController.text);
                  await user?.reload();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile Updated")),
                  );

                  Navigator.pop(context);
                },
                child: const Text(
                  "Save Update",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 🔥 COMMON FIELD WIDGET
  Widget _buildField({
    required String label,
    TextEditingController? controller,
    String? initial,
    bool readOnly = false,
    int maxLines = 1,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initial : null,
          readOnly: readOnly,
          maxLines: maxLines,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.grey[900]
                : Colors.grey[100],

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}