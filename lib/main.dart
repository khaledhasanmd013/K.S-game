import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const KSRacingApp());
}

class KSRacingApp extends StatelessWidget {
  const KSRacingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'K.S RACING',
      theme: ThemeData.dark(),
      home: const RacingScreen(),
    );
  }
}

enum Vehicle { auto, van, bike, bicycle }

String vehicleName(Vehicle v) {
  switch (v) {
    case Vehicle.auto:
      return 'অটোরিকশা 🛺';
    case Vehicle.van:
      return 'ভ্যান 🚐';
    case Vehicle.bike:
      return 'মোটরবাইক 🏍️';
    case Vehicle.bicycle:
      return 'বাইসাইকেল 🚲';
  }
}

class Traffic {
  Traffic(this.lane, this.y, this.type);
  int lane;
  double y;
  Vehicle type;
}

class RacingScreen extends StatefulWidget {
  const RacingScreen({super.key});

  @override
  State<RacingScreen> createState() => _RacingScreenState();
}

class _RacingScreenState extends State<RacingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timer;
  final Random _random = Random();
  final List<Traffic> _traffic = [];

  Vehicle _vehicle = Vehicle.auto;
  int _lane = 1;
  int _score = 0;
  int _lives = 3;

  double _spawnTime = 0;
  double _roadOffset = 0;

  DateTime _lastTick = DateTime.now();

  bool _playing = false;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();

    _timer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateGame);

    _timer.repeat();
  }

  void _updateGame() {
    if (!_playing || !mounted) {
      _lastTick = DateTime.now();
      return;
    }

    final now = DateTime.now();

    final dt = (now.difference(_lastTick).inMicroseconds /
            1000000)
        .clamp(0.0, 0.05)
        .toDouble();

    _lastTick = now;

    final speed = 0.48 + min(_score / 250, 0.55);

    setState(() {
      _roadOffset = (_roadOffset + dt * speed) % 1;
      _spawnTime += dt;

      if (_spawnTime > 1.0) {
        _spawnTime = 0;

        _traffic.add(
          Traffic(
            _random.nextInt(3),
            -0.15,
            Vehicle.values[_random.nextInt(4)],
          ),
        );
      }

      for (final item in List<Traffic>.from(_traffic)) {
        item.y += dt * speed;

        if (item.lane == _lane &&
            item.y > 0.72 &&
            item.y < 0.88) {
          _traffic.remove(item);
          _lives--;

          if (_lives <= 0) {
            _playing = false;
            _gameOver = true;
          }
          continue;
        }

        if (item.y > 1.12) {
          _traffic.remove(item);
          _score++;
        }
      }
    });
  }

  void _startGame() {
    setState(() {
      _traffic.clear();
      _score = 0;
      _lives = 3;
      _lane = 1;
      _spawnTime = 0;
      _roadOffset = 0;
      _gameOver = false;
      _playing = true;
      _lastTick = DateTime.now();
    });
  }

  void _moveLeft() {
    if (!_playing) return;
    setState(() {
      _lane = max(0, _lane - 1);
    });
  }

  void _moveRight() {
    if (!_playing) return;
    setState(() {
      _lane = min(2, _lane + 1);
    });
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  Widget _vehicleChoice(Vehicle v) {
    return ChoiceChip(
      label: Text(vehicleName(v)),
      selected: _vehicle == v,
      selectedColor: Colors.orange,
      onSelected: _playing
          ? null
          : (_) {
              setState(() => _vehicle = v);
            },
    );
  }

  Widget _menuPanel() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xEE142B35),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.orangeAccent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇧🇩', style: TextStyle(fontSize: 42)),
            const Text(
              'K.S RACING',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'বাংলাদেশি রেসিং গেম',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 14),
            const Text('তোমার বাহন নির্বাচন করো'),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: Vehicle.values
                  .map(_vehicleChoice)
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startGame,
                icon: const Icon(Icons.play_arrow),
                label: const Text('গেম শুরু করো'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(15),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Created by MD Khaled Hasan',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const Text(
              'Khaled 32',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 24,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontFamily: 'cursive',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameOverPanel() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(25),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xF0182934),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.orangeAccent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.flag,
              color: Colors.orange,
              size: 55,
            ),
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'তোমার স্কোর: $_score',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.replay),
              label: const Text('আবার খেলো'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Khaled 32',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 21,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hud(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _controlButton(
    IconData icon,
    VoidCallback action,
  ) {
    return SizedBox(
      width: 66,
      height: 58,
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Icon(icon, size: 36),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102B26),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '🏁 K.S RACING',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'বাংলাদেশ 🇧🇩',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      final velocity =
                          details.primaryVelocity ?? 0;

                      if (velocity < 0) {
                        _moveLeft();
                      } else if (velocity > 0) {
                        _moveRight();
                      }
                    },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: RoadPainter(
                        playerLane: _lane,
                        player: _vehicle,
                        traffic: _traffic,
                        roadOffset: _roadOffset,
                      ),
                    ),
                  ),
                  if (_playing)
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _hud('⭐ $_score'),
                          _hud('❤️ $_lives'),
                        ],
                      ),
                    ),
                  if (_playing)
                    Positioned(
                      bottom: 18,
                      left: 35,
                      right: 35,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _controlButton(
                            Icons.arrow_left,
                            _moveLeft,
                          ),
                          _controlButton(
                            Icons.arrow_right,
                            _moveRight,
                          ),
                        ],
                      ),
                    ),
                  if (!_playing && !_gameOver)
                    _menuPanel(),
                  if (_gameOver)
                    _gameOverPanel(),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'বাম-ডান বোতাম অথবা Swipe করে চালাও',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoadPainter extends CustomPainter {
  RoadPainter({
    required this.playerLane,
    required this.player,
    required this.traffic,
    required this.roadOffset,
  });

  final int playerLane;
  final Vehicle player;
  final List<Traffic> traffic;
  final double roadOffset;

  void drawVehicle(
    Canvas canvas,
    double x,
    double y,
    double laneWidth,
    Vehicle type,
    bool isPlayer,
  ) {
    final narrow =
        type == Vehicle.bike || type == Vehicle.bicycle;

    final w = laneWidth * (narrow ? 0.38 : 0.60);
    final h = laneWidth * 0.70;

    final color = isPlayer
        ? Colors.orange
        : type == Vehicle.auto
            ? Colors.greenAccent
            : type == Vehicle.van
                ? Colors.lightBlue
                : type == Vehicle.bike
                    ? Colors.redAccent
                    : Colors.yellow;

    final body = Paint()..color = color;
    final dark = Paint()..color = Colors.black87;
    final glass = Paint()..color = Colors.lightBlue.shade100;

    if (narrow) {
      final wheelR = h * 0.15;

      canvas.drawCircle(
        Offset(x, y - h * 0.32),
        wheelR,
        dark,
      );
      canvas.drawCircle(
        Offset(x, y + h * 0.32),
        wheelR,
        dark,
      );

      canvas.drawLine(
        Offset(x, y - h * 0.25),
        Offset(x, y + h * 0.25),
        Paint()
          ..color = color
          ..strokeWidth = 5,
      );

      canvas.drawCircle(
        Offset(x, y),
        h * 0.14,
        body,
      );

      if (type == Vehicle.bike) {
        canvas.drawCircle(
          Offset(x, y - h * 0.02),
          h * 0.10,
          glass,
        );
      }
    } else {
      final rect = Rect.fromCenter(
        center: Offset(x, y),
        width: w,
        height: h,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(9),
        ),
        body,
      );

      final window = Rect.fromCenter(
        center: Offset(x, y - h * 0.17),
        width: w * 0.67,
        height: h * 0.20,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          window,
          const Radius.circular(5),
        ),
        glass,
      );

      if (type == Vehicle.auto) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y + h * 0.18),
            width: w * 0.78,
            height: h * 0.22,
          ),
          Paint()..color = Colors.yellow.shade700,
        );
      }

      if (type == Vehicle.van) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y + h * 0.20),
            width: w * 0.75,
            height: h * 0.18,
          ),
          Paint()..color = Colors.white70,
        );
      }

      for (final side in [-1.0, 1.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x + side * w * 0.48, y),
              width: 5,
              height: h * 0.30,
            ),
            const Radius.circular(3),
          ),
          dark,
        );
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF235B37),
    );

    final roadLeft = width * 0.13;
    final roadWidth = width * 0.74;
    final laneWidth = roadWidth / 3;

    canvas.drawRect(
      Rect.fromLTWH(
        roadLeft,
        0,
        roadWidth,
        height,
      ),
      Paint()..color = const Color(0xFF34383B),
    );

    final edgePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(roadLeft, 0),
      Offset(roadLeft, height),
      edgePaint,
    );

    canvas.drawLine(
      Offset(roadLeft + roadWidth, 0),
      Offset(roadLeft + roadWidth, height),
      edgePaint,
    );

    final dashPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 3;

    for (int lane = 1; lane < 3; lane++) {
      final x = roadLeft + laneWidth * lane;

      for (int i = -1; i < 8; i++) {
        final y = ((i * 0.18 + roadOffset) % 1) * height;

        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + height * 0.09),
          dashPaint,
        );
      }
    }

    final playerX =
        roadLeft + laneWidth * (playerLane + 0.5);

    for (final item in traffic) {
      final x = roadLeft + laneWidth * (item.lane + 0.5);

      drawVehicle(
        canvas,
        x,
        item.y * height,
        laneWidth,
        item.type,
        false,
      );
    }

    drawVehicle(
      canvas,
      playerX,
      height * 0.80,
      laneWidth,
      player,
      true,
    );
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) {
    return true;
  }
}

