import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditrack/Auth/loginpage.dart';
import 'package:meditrack/Utils/app_text.dart' show AppText;
import 'package:meditrack/bottomnavigation/profile/editprofile.dart';
import 'package:meditrack/bottomnavigation/profile/imageuplaoded.dart';
import 'package:meditrack/main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late final lang = Localizations.localeOf(context).languageCode;
  bool notificationOn = true;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // 🔥 APP BAR
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
            ),
          ),
        ),
        title: Text(AppText.settings(lang),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 🔥 BODY
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
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6)
                ],
              ),
              child: Row(
                children: [

                  // 👤 IMAGE
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
                      radius: 35,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(Icons.camera_alt)
                          : null,
                    ),
                  ),

                  const SizedBox(width: 15),

                  // 👤 NAME + EMAIL
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder(
                          stream: FirebaseAuth.instance.userChanges(),
                          builder: (context, snapshot) {
                            final user = snapshot.data;

                            return Text(
                              user?.displayName ?? "User Name",
                              style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),
                            );
                          },
                        ),
                        Text(
                          user?.email ?? "",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 5),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EditProfilePage()),
                            );
                          },
                          child:  Text(
                            AppText.editProfile(lang),
                            style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 SETTINGS CARD
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [

                  // 🔔 NOTIFICATION
                  SwitchListTile(
                    value: notificationOn,
                    onChanged: (val) {
                      setState(() {
                        notificationOn = val;
                      });
                    },
                    title:  Text("${AppText.notifications(lang)}",style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold),),
                  ),

                  const Divider(),

                  // 🌙 THEME SWITCH
                SwitchListTile(

                  secondary: Icon(
                    MyApp.of(context).isDark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                 color: Colors.grey[700], ),
                  title: Text(
                    MyApp.of(context).isDark
                        ? "${AppText.darkMode(lang)}"
                        : "${AppText.lightMode(lang)}",
                      style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold)),
                  value: MyApp.of(context).isDark,
                  onChanged: (val) {
                    MyApp.of(context).changeTheme(val);
                  },
                ),

                  const Divider(),

                  // 🌐 LANGUAGE (dummy for now)
              ListTile(
                title:  Text(
                  "${AppText.language(lang)}",
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
                ),

                trailing: DropdownButtonHideUnderline(
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      color: Colors.grey.shade200, // 🔥 light background
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      value: Localizations.localeOf(context).languageCode,
                      dropdownColor: Colors.white, // 🔥 dropdown list color

                      items: const [
                        DropdownMenuItem(value: 'en', child: Text("English",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
                        DropdownMenuItem(value: 'bn', child: Text("বাংলা", style:TextStyle(fontWeight: FontWeight.bold,color: Colors.black),)),
                      ],

                      onChanged: (val) {
                        MyApp.of(context).changeLanguage(val!);
                      },
                    ),
                  ),
                ),
              ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔴 LOGOUT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                        (route) => false,
                  );
                },
                child:  Text("${AppText.logout(lang)}", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            )
          ],
        ),
      ),
    );
  }
}