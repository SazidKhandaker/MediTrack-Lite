import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class SmartActivityPage extends StatefulWidget {
  const SmartActivityPage({super.key});


  @override
  State<SmartActivityPage> createState() => _SmartActivityPageState();
}
enum ActivityType { running, walking, cycling }

ActivityType selectedActivity = ActivityType.running;

class _SmartActivityPageState extends State<SmartActivityPage> {


  /// 🔥 MAP
  GoogleMapController? mapController;

  /// 🔥 TIMER
  int seconds = 0;
  Timer? timer;
  bool running = false;

  /// 🔥 STEPS
  int steps = 0;
  int initialSteps = 0;
  StreamSubscription? stepStream;

  /// 🔥 DISTANCE (approx)
  double distance = 0;

  /// 🔥 CALORIES
  double calories = 0;

  @override
  void initState() {
    super.initState();
    markers = {
      Marker(
        markerId: const MarkerId("me"),
        position: currentLatLng,
      )
    };
    initPermission();
    initSteps();
    startLiveTracking();

  }

  /// 🔥 PERMISSION
  Future<void> initPermission() async {
    await Permission.activityRecognition.request();
  }

  /// 🔥 STEP LISTENER
  void initSteps() {
    stepStream = Pedometer.stepCountStream.listen((event) {
      setState(() {
        if (initialSteps == 0) {
          initialSteps = event.steps;
        }

        steps = event.steps - initialSteps;

        /// distance (avg 0.75m per step)
        distance = steps * 0.00075;

        /// calories
        calories = steps * 0.04;
        progress = steps / targetSteps;
        if (progress > 1) progress = 1;
      });
    });
  }

  /// 🔥 TIMER
  void start() {
    if (timer != null) return; // prevent multiple timers

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });

    setState(() {
      running = true;
    });
  }

  void stop() {
    timer?.cancel();
    timer = null;

    setState(() {
      running = false;
    });
  }

  void reset() {
    timer?.cancel();
    setState(() {
      seconds = 0;
      running = false;
      steps = 0;
      initialSteps = 0;
    });
    route.clear();
    polylines.clear();
  }

  String formatTime() {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }
  LatLng currentLatLng = const LatLng(23.8103, 90.4125);
  Set<Marker> markers = {};
  StreamSubscription<Position>? positionStream;
  Future<void> startLiveTracking() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    LatLng startPos = LatLng(position.latitude, position.longitude);

    setState(() {
      currentLatLng = startPos;

      markers = {
        Marker(
          markerId: const MarkerId("me"),
          position: startPos,
        )
      };
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLng(startPos),
    );

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      LatLng newPos = LatLng(position.latitude, position.longitude);

      setState(() {
        currentLatLng = newPos;

        // 🔥 route add
        route.add(newPos);

        // 🔥 marker update
        markers = {
          Marker(
            markerId: const MarkerId("me"),
            position: newPos,
          )
        };

        // 🔥 polyline draw
        polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            points: route,
            color: Colors.blue,
            width: 5,
          )
        };
      });

      // 🔥 smooth camera follow
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPos,
            zoom: 17,
          ),
        ),
      );
    });
  }
  List<LatLng> route = [];
  Set<Polyline> polylines = {};
  int targetSteps = 5000; // default
  double progress = 0;

  @override
  void dispose() {
    timer?.cancel();
    stepStream?.cancel();
    super.dispose();
    positionStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [

          /// 🔥 GOOGLE MAP
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLatLng,
              zoom: 16,
            ),
            markers: markers,
            polylines: polylines, // 🔥 ADD THIS
            myLocationEnabled: true,
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),

          /// 🔥 UI OVERLAY
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// 🔥 TOP CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [

                        const Icon(Icons.directions_walk,
                            size: 40, color: Colors.orange),

                        const SizedBox(width: 10),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$steps steps",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                "${distance.toStringAsFixed(2)} km | ${calories.toStringAsFixed(0)} kcal"),
                          ],
                        )
                      ],
                    ),
                  ),

                  const Spacer(),

                  /// 🔥 BOTTOM PANEL


                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      children: [

                        /// 🔥 MODE BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _modeButton("Running", ActivityType.running),
                            _modeButton("Walking", ActivityType.walking),
                            _modeButton("Cycling", ActivityType.cycling),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// 🔥 TIME + DISTANCE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Column(
                              children: [
                                Text(
                                  formatTime(),
                                  style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const Text("Elapsed time",
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),

                              Column(children: [


                                Icon(
                                  selectedActivity == ActivityType.running
                                      ? Icons.directions_run
                                      : selectedActivity == ActivityType.walking
                                      ? Icons.directions_walk
                                      : Icons.directions_bike,
                                  color: Colors.orange,
                                  size: 28,
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  selectedActivity == ActivityType.running
                                      ? "Keep running! 🔥"
                                      : selectedActivity == ActivityType.walking
                                      ? "Nice walk 👣"
                                      : "Keep cycling 🚴",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],


                              ),


                            Column(
                              children: [
                                Text(
                                  "${distance.toStringAsFixed(2)} km",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Text("Distance",
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// 🔥 STATS
                        Row(
                          children: [

                            Expanded(
                              child: _statCard(
                                icon: Icons.local_fire_department,
                                value: calories.toStringAsFixed(0),
                                label: "kcal",
                                color: Colors.orange,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: GestureDetector(
                                onTap: showTargetDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [

                                      /// 🔥 TITLE
                                      const Text(
                                        "Your Target",
                                        style: TextStyle(color: Colors.blue),
                                      ),

                                      const SizedBox(height: 6),

                                      /// 🔥 TARGET VALUE
                                      Text(
                                        "$targetSteps",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),

                                      const Text("steps", style: TextStyle(color: Colors.blue)),

                                      const SizedBox(height: 10),

                                      /// 🔥 PROGRESS BAR
                                      LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                        borderRadius: BorderRadius.circular(10),
                                        backgroundColor: Colors.white12,
                                        valueColor: const AlwaysStoppedAnimation(Colors.blue),
                                      ),

                                      const SizedBox(height: 6),

                                      /// 🔥 PERCENT
                                      Text(
                                        "${(progress * 100).toStringAsFixed(0)}% completed",
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// 🔥 CONTROL BUTTON
                        GestureDetector(
                          onTap: running ? stop : start,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: running ? Colors.red : Colors.green,
                              boxShadow: [
                                BoxShadow(
                                  color: (running ? Colors.red : Colors.green)
                                      .withOpacity(0.5),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: Icon(
                              running ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),


                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget _modeButton(String text, ActivityType type) {
    final isActive = selectedActivity == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedActivity = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.orange : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              type == ActivityType.running
                  ? Icons.directions_run
                  : type == ActivityType.walking
                  ? Icons.directions_walk
                  : Icons.directions_bike,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
  void showTargetDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// 🔥 TITLE
                const Text(
                  "🎯 Set Your Daily Target",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                /// 🔥 OPTIONS GRID
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _targetChip(2000),
                    _targetChip(5000),
                    _targetChip(8000),
                    _targetChip(10000),
                    _targetChip(15000),
                    _targetChip(20000),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔥 CLOSE BUTTON
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _targetChip(int value) {
    bool isSelected = targetSteps == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          targetSteps = value;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white24,
          ),
        ),
        child: Text(
          "$value",
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}