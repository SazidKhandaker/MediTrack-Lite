import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {

  int seconds = 0;
  Timer? timer;
  bool running = false;

  void start() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
    running = true;
  }

  void stop() {
    timer?.cancel();
    running = false;
  }

  void reset() {
    timer?.cancel();
    setState(() {
      seconds = 0;
      running = false;
    });
  }

  String format() {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stopwatch")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(format(),
                style: const TextStyle(fontSize: 40)),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  onPressed: running ? null : start,
                  child: const Text("Start"),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: running ? stop : null,
                  child: const Text("Pause"),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: reset,
                  child: const Text("Reset"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}