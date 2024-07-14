import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:sensors/sensors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // colorScheme: const ColorScheme.light(),
        useMaterial3: true,
        iconTheme: const IconThemeData(
          color: Color(0xFF444466)
        ),
        textTheme: const TextTheme(
          bodySmall: TextStyle(color: Color(0xFF112244)),
          bodyMedium: TextStyle(color: Color(0xFF112244)),
          bodyLarge: TextStyle(color: Color(0xFF112244)),
        ),
        scaffoldBackgroundColor: const Color(0xFF333344),
        // scaffoldBackgroundColor: const Color(0xFFE0E0E0),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFE0E0E0)
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double balance = 0;
  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // final a = [
    //   "10,000원 챌린지 D+17",
    //   "Demo text pairntlasdf",
    //   "10,000원 챌린지 D+19"
    // ];
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 24
          ),
          child: Center(
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 256,
                      height: 256,
                      decoration: const BoxDecoration(
                        // color: Color(0xFFE0E0E0),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF555566),
                            // color: Color(0xFF444455),
                            // color: Colors.white,
                            offset: Offset(-4, -4),
                            blurRadius: 12,
                            spreadRadius: 4,
                            blurStyle: BlurStyle.normal
                          ),
                          BoxShadow(
                            color: Color(0xFF222233),
                            // color: Color(0xFFBEBEBE),
                            offset: Offset(4, 4),
                            blurRadius: 12,
                            spreadRadius: 4,
                            blurStyle: BlurStyle.normal
                          )
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox.expand(
                        child: VisualBalance(
                          budget: 100,
                          balance: balance,
                        )
                      ),
                    ),
                    const SizedBox(height: 32),
                    Slider(
                      value: balance,
                      min: 0,
                      max: 100,
                      onChanged: (value) {
                        setState(() {
                          balance = value;
                        });
                      },
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VisualBalance extends StatelessWidget {
  final double budget;
  final double balance;

  const VisualBalance({
    super.key,
    required this.budget,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Processing(
      sketch: WaterLevelIndicator(
        containerWidth: 256,
        containerHeight: 256,
        value: balance / budget
      )
    );
  }
}

class WaterLevelIndicator extends Sketch {
  final int containerWidth;
  final int containerHeight;
  final double value;

  late double _theta;
  late PVector _acceleration;
  late List<double> xs;

  static const int resolution = 16;
  static const double step = 0.5;
  static const double scale = 64;
  static const double smooth = 0.03125;

  WaterLevelIndicator({
    required this.containerWidth,
    required this.containerHeight,
    required this.value,
  });

  @override
  Future<void> setup() async {
    frameRate = 60;
    size(width: containerWidth, height: containerHeight);
    background(color: const Color(0xFF333344));
    // background(color: const Color(0xFFE0E0E0));

    _acceleration = PVector(0, 0);
    accelerometerEvents.listen((e) {
      _acceleration.x = e.x;
      _acceleration.y = e.y;
    });
    _theta = 0;
    xs = List.generate(resolution, (i) => width * i / (resolution - 1));

    noiseSeed(DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<void> draw() async {
    background(color: const Color(0xFF333344));
    // background(color: const Color(0xFFE0E0E0));

    final w1 = xs.map((x) {
      final n = noise(
        x: (x + frameCount) * step,
        y: frameCount * step
      );
      // final y = 128 + n * scale;
      final y = map(constrain(value, 0, 1), 0, 1, height, 0) + n * scale;

      return Offset(x, y);
    }).toList();
    final w2 = xs.map((x) {
      final n = noise(
        x: (x + frameCount) * step,
        z: frameCount * step
      );
      // final y = 128 + n * scale;
      final y = map(constrain(value, 0, 1), 0, 1, height, 0) + n * scale;

      return Offset(x, y);
    }).toList();
    final ofs = Offset(width/2, height/2);

    pushMatrix();

    translate(x: ofs.dx, y: ofs.dy);
    rotate(_theta);

    fill(color: Colors.lightBlueAccent);
    stroke(color: Colors.lightBlueAccent);
    strokeWeight(1);
    for (int i = 0; i < w1.length-1; i++) {
      quad(
        w1[i] - ofs,
        Offset(w1[i].dx, height.toDouble()) - ofs,
        Offset(w1[i+1].dx, height.toDouble()) - ofs,
        w1[i+1] - ofs
      );
    }

    fill(color: Colors.blue);
    stroke(color: Colors.blue);
    strokeWeight(1);
    for (int i = 0; i < w2.length-1; i++) {
      quad(
        w2[i] - ofs,
        Offset(w2[i].dx, height.toDouble()) - ofs,
        Offset(w2[i+1].dx, height.toDouble()) - ofs,
        w2[i+1] - ofs
      );
    }

    popMatrix();

    final origin = PVector(0, 1);
    final normalized = _acceleration / _acceleration.mag;
    final dotted = origin.dot(normalized);
    final theta = _acceleration.x >= 0 ? acos(dotted) : -acos(dotted);
    if (!theta.isNaN && _acceleration.mag >= 4.9) {
      _theta += (theta - _theta) * smooth;
    }
  }
}
