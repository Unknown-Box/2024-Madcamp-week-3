import 'dart:async';
import 'dart:math';

import 'package:demo/src/utils/provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_processing/flutter_processing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
  var pc = PageController(initialPage: 1);
  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 24
          ),
          child: Center(
            child: Stack(
              children: [
                PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pc,
                  onPageChanged: (idx) {},
                  children: [
                    SizedBox.expand(),
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
                            child: VisualBalance()
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          '₩100,000',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        NewWidget(),
                      ],
                    ),
                    Center(
                      child: Container(
                        width: 400,
                        height: 200,
                        color: Colors.white,
                        transform: Matrix4.rotationZ(pi/2),
                        transformAlignment: Alignment.center,
                        child: Center(
                          child: Text('hello'),
                        ),
                      ),
                    ),
                  ]
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      // border: Border.all(
                      //   color: Colors.white
                      // ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (_) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 8,
                        ),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Container(
                            width: 32,
                            height: 32,
                            color: Colors.grey,
                          ),
                        ),
                      )),
                    )
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

class NewWidget extends StatefulWidget {
  const NewWidget({ super.key });

  @override
  State<NewWidget> createState() => _NewWidgetState();
}

class _NewWidgetState extends State<NewWidget> {
  @override
  Widget build(BuildContext context) {
    final provider = StateProvider();
    return Slider(
      value: provider.balance.balance,
      min: 0,
      max: 100,
      onChanged: (value) {
        setState(() {
          provider.balance.balance = value;
        });
      },
    );
  }
}

class VisualBalance extends StatelessWidget {
  const VisualBalance({ super.key });

  @override
  Widget build(BuildContext context) {
    return Processing(
      sketch: WaterLevelIndicator(
        containerWidth: 256,
        containerHeight: 256,
      )
    );
  }
}

class WaterLevelIndicator extends Sketch {
  final int containerWidth;
  final int containerHeight;

  late double _h;
  late double _theta;
  late PVector _acceleration;

  late List<double> xs;

  static const int resolution = 32;
  static const double step = 0.5;
  static const double scale = 64;
  static const double smooth = 0.03125;

  WaterLevelIndicator({
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Future<void> setup() async {
    frameRate = 60;
    size(width: containerWidth, height: containerHeight);
    background(color: const Color(0xFF333344));
    // background(color: const Color(0xFFE0E0E0));

    xs = List.generate(
      resolution,
      (i) => width * i / (resolution - 1)
    );
    _h = 0;
    _theta = 0;
    _acceleration = PVector(0, 0);

    StateProvider().balance.budget = 100;
    noiseSeed(DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<void> draw() async {
    background(color: const Color(0xFF333344));
    // background(color: const Color(0xFFE0E0E0));

    final provider = StateProvider();
    final value = provider.balance.value;
    final h = map(constrain(value, 0, 1), 0, 1, height, 0);

    _h += (h - _h) * smooth;

    final w1 = xs.map((x) {
      final n = noise(
        x: (x + frameCount) * step,
        y: frameCount * step
      );
      final y = _h - n * scale;

      return Offset(x, y);
    }).toList();
    final w2 = xs.map((x) {
      final n = noise(
        x: (x + frameCount) * step,
        z: frameCount * step
      );
      final y = _h - n * scale;

      return Offset(x, y);
    }).toList();
    final w3 = xs.map((x) {
      final n = noise(
        x: (x + frameCount) * step,
        y: frameCount * step,
        z: frameCount * step
      );
      final y = _h - n * scale;

      return Offset(x, y);
    }).toList();
    final al = (256 * 0.8).round();
    final ofs = Offset(width/2, height/2);

    pushMatrix();

    translate(x: ofs.dx, y: ofs.dy);
    rotate(_theta);

    stroke(color: Colors.white);
    strokeWeight(1);
    line(
      Offset(0, -height/2 + 8),
      Offset(0, -height/2 + 16)
    );

    pushMatrix();

    rotate(-_theta);
    translate(x: -ofs.dx, y: -ofs.dy);

    final int amberlevel = constrain(
      map(abs(_theta - pi / 2), 0, 0.1, 6, 1),
      1,
      6
    ).round() * 100;
    fill(color: Colors.amber[amberlevel]!);
    noStroke();
    circle(center: Offset(width - 12, height/2), diameter: 16);

    popMatrix();

    fill(color: Colors.lightBlue.withAlpha(al));
    stroke(color: Colors.lightBlue.withAlpha(al));
    strokeWeight(1);
    beginShape();
    vertex(0 - ofs.dx, height + 16 - ofs.dy);
    for (int i = 0; i < w3.length; i++) {
      vertex(w3[i].dx - ofs.dx, w3[i].dy - ofs.dy);
    }
    vertex(width - ofs.dx, height + 16 - ofs.dy);
    endShape(close: true);

    fill(color: Colors.lightBlueAccent.withAlpha(al));
    stroke(color: Colors.lightBlueAccent.withAlpha(al));
    strokeWeight(1);
    beginShape();
    vertex(0 - ofs.dx, height + 16 - ofs.dy);
    for (int i = 0; i < w1.length; i++) {
      vertex(w1[i].dx - ofs.dx, w1[i].dy - ofs.dy);
    }
    vertex(width - ofs.dx, height + 16 - ofs.dy);
    endShape(close: true);

    fill(color: Colors.blue.withAlpha(al));
    stroke(color: Colors.blue.withAlpha(al));
    strokeWeight(1);
    beginShape();
    vertex(0 - ofs.dx, height + 16 - ofs.dy);
    for (int i = 0; i < w2.length; i++) {
      vertex(w2[i].dx - ofs.dx, w2[i].dy - ofs.dy);
    }
    vertex(width - ofs.dx, height + 16 - ofs.dy);
    endShape(close: true);

    popMatrix();

    _acceleration = PVector(provider.sensors.ax, provider.sensors.ay);

    final origin = PVector(0, 1);
    final normalized = _acceleration / _acceleration.mag;
    final dotted = origin.dot(normalized);
    final theta = _acceleration.x >= 0 ? acos(dotted) : -acos(dotted);
    if (!theta.isNaN && _acceleration.mag >= 4.9) {
      _theta += (theta - _theta) * smooth;
    }
  }
}
