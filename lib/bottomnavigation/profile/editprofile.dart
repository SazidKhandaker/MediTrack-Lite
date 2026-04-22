import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditrack/bottomnavigation/profile/imageuplaoded.dart'
    show uploadToCloudinary;
import 'package:meditrack/bottomnavigation/profile/profilepage.dart' show ProfilePage;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  User? user;

  final nameController = TextEditingController();
  final aboutController = TextEditingController();

  bool isEditingAbout = false;

  @override
  void initState() {
    super.initState();

    user = FirebaseAuth.instance.currentUser;

    // 🔥 Name always Firebase থেকে
    nameController.text = user?.displayName ?? "User Name";

    loadData();
  }
  bool isLoading = true;
  // 🔥 About → Firestore থেকে load
  Future<void> loadData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        aboutController.text = doc['about'] ?? "";
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false; // 🔥 DONE LOADING
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Your Profile",style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔥 PROFILE IMAGE
            GestureDetector(
              onTap: () async {
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

            // 🔥 CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  // 👤 FULL NAME
                  _buildField(
                    label: "Full Name",
                    controller: nameController,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 15),

                  // 📧 EMAIL
                  _buildField(
                    label: "Email Address",
                    initial: user?.email ?? "",
                    readOnly: true,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 15),

                  // 🔥 ABOUT HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "About Me",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(isEditingAbout ? Icons.check : Icons.edit),
                        onPressed: () async {

                          if (isEditingAbout) {

                            // 🔥 SAVE
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .set({
                              "about": aboutController.text,
                            }, SetOptions(merge: true));

                            // 🔥 FIRST → snackbar
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("About Updated"),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            // 🔥 WAIT
                            await Future.delayed(const Duration(seconds: 1));

                            // 🔥 NAVIGATE
                            Navigator.pop(context, true);

                            return; // 🔥 VERY IMPORTANT
                          }

                          // 🔥 ONLY edit mode toggle
                          setState(() {
                            isEditingAbout = true;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 🔥 ABOUT BODY
                  isEditingAbout
                      ? TextField(
                    controller: aboutController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Write about yourself...",
                    ),
                  )
                      : isLoading
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      aboutController.text.isEmpty
                          ? "No bio added"
                          : aboutController.text,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // onPressed: () async {
                //   final user = FirebaseAuth.instance.currentUser;
                //
                //   if (user == null) return;
                //
                //   // 🔥 update name
                //   await user.updateDisplayName(nameController.text.trim());
                //   await user.reload();
                //
                //   // 🔥 snackbar show
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(
                //       content: Text("Profile Updated"),
                //       duration: Duration(seconds: 1),
                //     ),
                //   );
                //
                //   // 🔥 wait then back
                //   await Future.delayed(const Duration(seconds: 1));
                //
                //   Navigator.pop(context, true);
                // },
                onPressed: () async {
                  try {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) return;

                    // 🔥 NAME UPDATE (Firebase Auth)
                    await user.updateDisplayName(nameController.text.trim());
                    await user.reload();

                    // 🔥 ABOUT (optional Firestore - error হলেও app crash হবে না)
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .set({
                        "about": aboutController.text,
                      }, SetOptions(merge: true));
                    } catch (e) {
                      print("Firestore error ignored: $e");
                    }

                    // 🔥 1️⃣ Snackbar show
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile Updated Successfully"),
                        duration: Duration(milliseconds: 800),
                      ),
                    );

                    // 🔥 2️⃣ একটু wait (important)
                    await Future.delayed(const Duration(milliseconds: 900));

                    // 🔥 3️⃣ তারপর back
                    Navigator.pop(context, true);

                  } catch (e) {
                    print("Error: $e");

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Update Failed")),
                    );
                  }
                },
                child: const Text(
                  "Save Update",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

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
            fillColor:
            isDark ? Colors.grey[900] : Colors.grey[100],
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