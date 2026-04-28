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
    await Geolocator.requestPermission();

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      LatLng newPos = LatLng(position.latitude, position.longitude);

      setState(() {
        currentLatLng = newPos;

        markers = {
          Marker(
            markerId: const MarkerId("me"),
            position: newPos,
          )
        };
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLng(newPos),
      );
    });
  }
  @override
  void dispose() {
    timer?.cancel();
    stepStream?.cancel();
    super.dispose();
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
                    padding: const EdgeInsets.all(20),
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
                            _modeButton("Running", true),
                            _modeButton("Walking", false),
                            _modeButton("Cycling", false),
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
                              child: _statCard(
                                icon: Icons.favorite,
                                value: "110",
                                label: "bpm",
                                color: Colors.red,
                              ),
                            ),
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
  Widget _modeButton(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.orange : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.white70,
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
}