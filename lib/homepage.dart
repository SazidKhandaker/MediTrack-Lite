import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditrack/Utils/app_text.dart' show AppText;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meditrack/widget/notification_service.dart' show NotificationService;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:timezone/timezone.dart' as tz;
import 'package:meditrack/bottomnavigation/profile/profilepage.dart';
import 'package:meditrack/bottomnavigation/Myactivities/MyActivitiesPage.dart';
import 'package:meditrack/singlepagedetailse.dart' show MedicineDetailPage;
import 'bottomnavigation/AddPage.dart';
import 'bottomnavigation/Listpage.dart';
 // 🔥 language file

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isNotificationOn = false;
  Map<String, int> parseTime(String time) {

    // 🔥 Bangla → English convert
    const bn = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    const en = ['0','1','2','3','4','5','6','7','8','9'];

    for (int i = 0; i < bn.length; i++) {
      time = time.replaceAll(bn[i], en[i]);
    }

    final parts = time.split(":");

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1].split(" ")[0]);

    if (time.contains("PM") && hour != 12) hour += 12;
    if (time.contains("AM") && hour == 12) hour = 0;

    return {"hour": hour, "minute": minute};
  }
  Future<void> scheduleAllFromDB() async {
    final user = FirebaseAuth.instance.currentUser;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medicines')
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final time = parseTime(data['time']);

      await NotificationService.scheduleMedicine(
        name: data['name'],
        hour: time['hour']!,
        minute: time['minute']!,
        beforeMin: 1,
      );
    }
  }
  Future<void> loadNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isNotificationOn = prefs.getBool('notification') ?? false;
    });
  }

  Future<void> saveNotificationState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification', value);
  }

  @override
  void initState() {
    super.initState();
    loadNotificationState(); // 🔥 important
    Future.delayed(Duration.zero, () async {
      final prefs = await SharedPreferences.getInstance();
      bool isOn = prefs.getBool('notification') ?? false;

      if (isOn) {
        // 🔥 auto schedule
        final user = FirebaseAuth.instance.currentUser;

        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('medicines')
            .get();

        if (isOn) {
          await scheduleAllFromDB();
        }
      }});
  }
  DateTime selectedDate = DateTime.now();

  // 🔥 Firebase stream
  Stream<QuerySnapshot> getMedicines() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medicines')
        .snapshots();
  }

  // 🔥 progress calc
  double getProgress(List docs) {
    if (docs.isEmpty) return 0;

    int taken = docs.where((d) {
      final data = d.data() as Map<String, dynamic>;
      return data['status'] == true;
    }).length;

    return taken / docs.length;
  }
  void navigateTo(int index) {
    Widget page;

    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const MyActivitiesPage ();
        break;
      case 2:
        page = const AddPage();
        break;
      case 3:
        page = const ListPage();
        break;
      case 4:
        page = const ProfilePage();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
  int centerIndex = 50;


  @override
  Widget build(BuildContext context) {


    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // 🔻 Bottom nav SAME
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
        
              GestureDetector(
                onTap: () => navigateTo(0),
                child: const Icon(Icons.grid_view, color: Colors.blue),
              ),
        
              GestureDetector(
                onTap: () => navigateTo(1),
                child: const Icon(Icons.local_activity, color: Colors.grey),
              ),
        
              GestureDetector(
                onTap: () => navigateTo(2),
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E8B57), Color(0xFF4CAF50)],
                    ),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
        
              GestureDetector(
                onTap: () => navigateTo(3),
                child: const Icon(Icons.list_alt, color: Colors.grey),
              ),
        
              // 🔥 PROFILE CLICK FIXED
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                  setState(() {});
                },
                child: StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.userChanges(),
                  builder: (context, snapshot) {
        
                    final user = snapshot.data;
        
                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL! +
                          "?t=${DateTime.now().millisecondsSinceEpoch}")
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔝 HEADER
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  Expanded(
                    child: Text(
                      AppText.reminder(lang),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                   SizedBox(width: 8),
                  Row(
                    children: [

                      Column(
                        children: [
                          GestureDetector(
                  onTap: () async {
    setState(() {
    isNotificationOn = !isNotificationOn;
    });

    await saveNotificationState(isNotificationOn);

    if (isNotificationOn) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Reminder ON 🔔")),
    );

    // 🔥 FETCH FROM FIREBASE
    final user = FirebaseAuth.instance.currentUser;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medicines')
        .get();

    // 🔥 LOOP + schedule
    if (isNotificationOn) {

      await scheduleAllFromDB(); // 🔥 clean

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reminder ON 🔔")),
      );

    } else {

      await NotificationService.cancelAll();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reminder OFF 🔕")),
      );
    }

    } else {
    // 🔴 OFF → cancel সব
    await NotificationService.cancelAll();

    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Reminder OFF 🔕")),
    );
    }
    }

                            ,child: Container(
                              margin: EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isNotificationOn   ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isNotificationOn
                                    ? Icons.notifications_active
                                    : Icons.notifications_off,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // 🔥 status text
                          Text(
                            isNotificationOn
                                ? "Reminder ON"
                                : "Reminder OFF",
                            style: TextStyle(
                              fontSize: 10,
                              color: isNotificationOn  ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                       SizedBox(width: 6),

                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfilePage()),
                          );
                          setState(() {});
                        },
                        child: StreamBuilder<User?>(
                          stream:
                          FirebaseAuth.instance.userChanges(),
                          builder: (context, snapshot) {

                            final user = snapshot.data;

                            return CircleAvatar(
                              radius: 20,
                              backgroundColor:
                              Colors.grey.shade300,
                              backgroundImage:
                              user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!)
                                  : null,
                              child: user?.photoURL == null
                                  ? const Icon(Icons.person,
                                  color: Colors.grey)
                                  : null,
                            );
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              // 📅 FULL MONTH CALENDAR
            SizedBox(
              height: 90,
              child: ListView.builder(
                controller: ScrollController(
                  initialScrollOffset: centerIndex * 72,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: 100,
                itemBuilder: (context, index) {

                  DateTime date =
                  DateTime.now().add(Duration(days: index - centerIndex));

                  bool isSelected =
                      date.year == selectedDate.year &&
                          date.month == selectedDate.month &&
                          date.day == selectedDate.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                    child: _dateItem(
                      date,
                      isSelected,
                    ),
                  );
                },
              ),
            ),

              const SizedBox(height: 15),

              // 🔥 PROGRESS
              Text(AppText.progress(lang),
                  style: const TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 6),

              // 🔥 FIREBASE LIST + PROGRESS
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getMedicines(),
                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var docs = snapshot.data!.docs;

                    var filtered = docs.where((doc) {
                      var formatted = formatDate(selectedDate);

                      var altFormat =
                          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                      return doc['date'] == formatted || doc['date'] == altFormat;
                    }).toList();

                    return Column(
                      children: [

                        LinearProgressIndicator(
                          value: getProgress(filtered),
                          color: Colors.green,
                          backgroundColor: Colors.grey.shade300,
                        ),

                        const SizedBox(height: 20),

                        // ❌ EMPTY UI
                        if (filtered.isEmpty)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.medication_outlined,
                                      size: 80,
                                      color: Colors.grey),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppText.noMedicine(lang),
                                    style: const TextStyle(
                                        fontWeight:
                                        FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          )

                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {

                                var data = filtered[index];
                                final map = data.data() as Map<String, dynamic>;
                                bool isTaken = map['status'] == true;


                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  padding: const EdgeInsets.all(16),

                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFF1E293B) // 🔥 dark card color
                                        : Colors.white,

                                    borderRadius: BorderRadius.circular(18),

                                    // 🔥 THICK BORDER
                                    border: Border.all(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.greenAccent // dark mode border
                                          : Colors.green,      // light mode border
                                      width: 2.2,
                                    ),

                                    // 🔥 SHADOW
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children:[


                                      Column(

                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [

                                        Text(data['name'],
                                            style: const TextStyle(
                                                fontWeight:
                                                FontWeight.bold)),

                                        Text(AppText.meal(lang, data['meal'])),

                                        Text("${AppText.nextDose(lang)} ${data['time']}",
                                            style: const TextStyle(
                                                color: Colors.orange)),

                                        const SizedBox(height: 10),

                                        Row(


                                          children: [

                                            ElevatedButton(
                                            onPressed: () async {

                                                                    bool? confirm = await showDialog(
                                                                    context: context,
                                                                    builder: (context) => AlertDialog(
                                                                    backgroundColor: Colors.green[200],
                                                                    title: const Text("Confirm"),
                                                                    content: const Text("Are you sure you took this medicine?"),
                                                                    actions: [
                                                                    TextButton(
                                                                    onPressed: () => Navigator.pop(context, false),
                                                                    child: const Text("No"),
                                                                    ),
                                                                    ElevatedButton(
                                                                    onPressed: () => Navigator.pop(context, true),
                                                                    child: const Text("Yes"),
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
                                                                              .doc(filtered[index].id)
                                                                              .update({
                                                                    "status": true,
                                                                    });

                                                                    // ❌ no setState needed
                                                                    }
                                                                    },
                                              child: Text(AppText.taken(lang)),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green),
                                            ),

                                             SizedBox(width: 5),

                                            ElevatedButton(
                                              onPressed: () async {

                                                bool? confirm = await showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    backgroundColor: Colors.red[200],
                                                    title: const Text("Confirm"),
                                                    content: const Text("Mark as missed?"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, false),
                                                        child: const Text("No"),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () => Navigator.pop(context, true),
                                                        child: const Text("Yes"),
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
                                                      .doc(filtered[index].id)
                                                      .update({
                                                    "status": false,
                                                  });
                                                }
                                              },
                                              child: Text(AppText.missed(lang)),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                            ),

                                          ],
                                        ),

                                        const SizedBox(height: 6),

                                        Text(
                                          isTaken
                                              ? "✔ Taken"
                                              : "❌ Not taken",
                                          style: TextStyle(
                                            color: isTaken
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        )
                                      ],
                                    ),

                                      GestureDetector(
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MedicineDetailPage(data: data,),
                                            ),
                                          );

                                        },


                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),


                                    ],
                                  ),


                                );
                              },
                            ),
                          )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget  _dateItem(DateTime date, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 65,
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // 📅 DAY
          Text(
            "${date.day}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),

          // 📅 WEEK
          Text(
            ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
            [date.weekday % 7],
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),

          const SizedBox(height: 4),

          // 🔥 FIXED MONTH (IMPORTANT)
          Text(
            _getMonthName(date.month),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
  String _getMonthName(int month) {
    const months = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    return months[month - 1];
  }
  String formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }
}