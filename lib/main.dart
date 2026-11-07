import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const KSRacing());
}

class KSRacing extends StatelessWidget {
  const KSRacing({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'K.S RACING',
      theme: ThemeData.dark(),
      home: const RacingHome(),
    );
  }
}

class RacingHome extends StatefulWidget {
  const RacingHome({super.key});

  @override
  State<RacingHome> createState() => _RacingHomeState();
}

class _RacingHomeState extends State<RacingHome> {
  final Random random = Random();
  Timer? timer;

  bool playing = false;
  int score = 0;
  int lives = 3;
  int lane = 1;
  double roadOffset = 0;
  String vehicle = '🚗';
  final List<Map<String, double>> traffic = [];

  void startGame() {
    timer?.cancel();
    setState(() {
      score = 0;
      lives = 3;
      lane = 1;
      roadOffset = 0;
      traffic.clear();
      playing = true;
    });

    timer = Timer.periodic(const Duration(milliseconds: 45), (t) {
      if (!mounted || !playing) return;

      setState(() {
        roadOffset = (roadOffset + 7) % 50;
        score++;

        if (random.nextInt(28) == 0) {
          traffic.add({
            'lane': random.nextInt(3).toDouble(),
            'y': -80,
          });
        }

        for (final car in traffic) {
          car['y'] = car['y']! + 7;
        }

        for (int i = traffic.length - 1; i >= 0; i--) {
          if (traffic[i]['y']! > 620) {
            traffic.removeAt(i);
          } else if (traffic[i]['lane'] == lane &&
              traffic[i]['y']! > 430 &&
              traffic[i]['y']! < 510) {
            traffic.removeAt(i);
            lives--;
            if (lives <= 0) {
              playing = false;
              timer?.cancel();
              break;
            }
          }
        }
      });
    });
  }

  void move(int direction) {
    if (!playing) return;
    setState(() {
      lane = (lane + direction).clamp(0, 2);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'K.S RACING',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const Text(
              'BANGLADESH VEHICLE RACING',
              style: TextStyle(color: Colors.white70),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('SCORE: $score'),
                  Text('LIVES: $lives'),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    move(1);
                  } else {
                    move(-1);
                  }
                },
                child: Container(
                  color: Colors.green.shade800,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: RoadPainter(roadOffset),
                        ),
                      ),
                      for (final car in traffic)
                        Positioned(
                          left: MediaQuery.of(context).size.width *
                                  0.16 +
                              car['lane']! *
                                  MediaQuery.of(context).size.width *
                                  0.27,
                          top: car['y'],
                          child: const Text(
                            '🚙',
                            style: TextStyle(fontSize: 38),
                          ),
                        ),
                      Positioned(
                        bottom: 28,
                        left: MediaQuery.of(context).size.width *
                                0.16 +
                            lane *
                                MediaQuery.of(context).size.width *
                                0.27,
                        child: Text(
                          vehicle,
                          style: const TextStyle(fontSize: 43),
                        ),
                      ),
                      if (!playing)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  lives == 0
                                      ? 'GAME OVER'
                                      : 'READY TO RACE?',
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton(
                                  onPressed: startGame,
                                  child: const Text('START RACE'),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Created by MD Khaled Hasan',
              style: TextStyle(color: Colors.white70),
            ),
            const Text(
              'Khaled 32',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => move(-1),
                  icon: const Icon(Icons.arrow_back),
                ),
                DropdownButton<String>(
                  value: vehicle,
                  dropdownColor: Colors.blueGrey,
                  items: const [
                    DropdownMenuItem(value: '🚗', child: Text('Car')),
                    DropdownMenuItem(value: '🛺', child: Text('Auto-rickshaw')),
                    DropdownMenuItem(value: '🏍️', child: Text('Motorcycle')),
                    DropdownMenuItem(value: '🚲', child: Text('Bicycle')),
                    DropdownMenuItem(value: '🚐', child: Text('Van')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => vehicle = value);
                    }
                  },
                ),
                IconButton(
                  onPressed: () => move(1),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RoadPainter extends CustomPainter {
  final double offset;

  RoadPainter(this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()..color = const Color(0xFF424242);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.12, 0, size.width * 0.76, size.height),
      road,
    );

    final line = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    for (double x in [size.width * 0.37, size.width * 0.63]) {
      for (double y = -50 + offset; y < size.height; y += 50) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + 25),
          line,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) => true;
}
