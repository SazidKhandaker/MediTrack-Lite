import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditrack/Auth/loginpage.dart' show LoginPage;
import 'package:meditrack/bottomnavigation/profile/editprofile.dart' show EditProfilePage;
import 'package:meditrack/bottomnavigation/profile/imageuplaoded.dart' show pickAndUploadImage, uploadToImgur, uploadToCloudinary;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final user = FirebaseAuth.instance.currentUser;

  bool notificationOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2F9E5B),
                Color(0xFF2E8B57),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(Icons.settings, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔥 PROFILE HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6)
                ],
              ),
              child: Row(
                children: [

                  // 👤 Profile Image
                  GestureDetector(
                    onTap: () async {
                      await uploadToCloudinary();
                      setState(() {});
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Icon(Icons.person)
                          : null,
                    ),
                  ),

                  const SizedBox(width: 15),

                  // 👤 Name + Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (user?.displayName?.isNotEmpty ?? false)
                              ? user!.displayName!
                              : "User Name",

                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          user?.email ?? "",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 5),

                        // ✏️ Edit Profile
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EditProfilePage()),
                            );
                          },
                          child: const Text(
                            "Edit profile",
                            style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 SETTINGS LIST
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [

                  // 🔔 Notification
                  SwitchListTile(
                    value: notificationOn,
                    onChanged: (val) {
                      setState(() {
                        notificationOn = val;
                      });
                    },
                    title: const Text("Notifications"),
                  ),

                  const Divider(),

                  ListTile(
                    title: const Text("Theme mode"),
                    trailing: const Text("Light"),
                  ),

                  ListTile(
                    title: const Text("Language"),
                    trailing: const Text("English"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔴 LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) =>  LoginPage()),
                        (route) => false,
                  );
                },
                child: const Text("Logout"),
              ),
            )
          ],
        ),
      ),
    );
  }
}