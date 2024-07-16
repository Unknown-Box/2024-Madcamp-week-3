import 'dart:math';
import 'dart:async';

import 'package:demo/src/utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

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
  late PVector _a;

  late List<double> xs;
  int timer = 0;

  static const int resolution = 32;
  static const double step = 0.5;
  static const double scale = 64;
  static const double smooth = 0.03125;
  static const double thetaStart = -pi * 30 / 180;

  WaterLevelIndicator({
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Future<void> setup() async {
    frameRate = 60;
    size(width: containerWidth, height: containerHeight);
    background(color: const Color(0xFF333344));

    _h = 0;
    _theta = 0;
    _a = PVector(0, 0);
    xs = List.generate(
      resolution,
      (i) => width * i / (resolution - 1)
    );

    StateProvider().balance.budget = 100;
    noiseSeed(DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<void> draw() async {
    background(color: const Color(0xFF333344));

    final provider = StateProvider();
    final value = provider.balance.value;
    final h = map(constrain(value, 0, 1), 0, 1, height, 0);

    _h += (h - _h) * smooth;
    _a = PVector(provider.sensors.ax, provider.sensors.ay);

    final origin = PVector(0, 1);
    final normalized = _a / _a.mag;
    final dotted = origin.dot(normalized);
    final theta = _a.x >= 0 ? acos(dotted) : -acos(dotted);
    if (!theta.isNaN && _a.mag >= 4.9) {
      _theta += (theta - _theta) * smooth;
    }
    final int amberlevel = constrain(
      map(abs(_theta - thetaStart), 0, 0.1, 7, 1),
      1,
      6
    ).round() * 100;

    timer = amberlevel >= 400 ? timer + 1 : 0;
    if (timer >= 180) {
      provider.balance.balance = provider.balance.budget;
      Timer(
        const Duration(milliseconds: 1000),
        () async {
          await provider.pc.nextPage(
            duration: const Duration(seconds: 1),
            curve: Curves.ease
          );
          timer = 0;
          provider.balance.balance = 30;
        }
      );

      timer = 0;
    }

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
    strokeWeight(2);
    line(
      Offset(0, -height/2 + 8),
      Offset(0, -height/2 + 16)
    );

    pushMatrix();

    rotate(-_theta + thetaStart);

    fill(color: Colors.amber[amberlevel]!);
    noStroke();
    circle(center: Offset(0, -height/2 + 12), diameter: 16);

    popMatrix();

    fill(color: Colors.lightBlue.withAlpha(255));
    stroke(color: Colors.lightBlue.withAlpha(255));
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
  }
}
