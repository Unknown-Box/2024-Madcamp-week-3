import 'dart:math';
import 'dart:async';

import 'package:demo/src/utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

class VisualLeak extends StatelessWidget {
  const VisualLeak({ super.key });

  @override
  Widget build(BuildContext context) {
    return Processing(sketch: LeakIndicator(
      deviceWidth: MediaQuery.of(context).size.width,
      deviceHeight: MediaQuery.of(context).size.height,
      containerWidth: 256,
      containerHeight: 256,
    ));
  }
}

class LeakIndicator extends Sketch {
  final double deviceWidth;
  final double deviceHeight;
  final int containerWidth;
  final int containerHeight;

  late int timer;
  late StateProvider provider;

  late final PImage bgimg1;
  late final PImage bgimg2;
  late final PVector leakPoint;
  late final List<PImage> icons;
  late final List<WaterDrop> drops;

  LeakIndicator({
    required this.deviceWidth,
    required this.deviceHeight,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Future<void> setup() async {
    frameRate = 60;
    size(width: containerWidth, height: containerHeight);
    background(color: const Color(0xFF333344));

    timer = 0;
    provider = StateProvider();

    bgimg1 = await loadImage('assets/b1b.png');
    bgimg2 = await loadImage('assets/b2.png');

    leakPoint = PVector(104, 88);

    const iconPathes = [
      "assets/categories/clothes-b.png",
      "assets/categories/cosmetic-b.png",
      "assets/categories/drinks-b.png",
      "assets/categories/finance-b.png",
      "assets/categories/living-b.png",
      "assets/categories/meal-b.png",
      "assets/categories/medical-b.png",
      "assets/categories/mobile-b.png",
      "assets/categories/mobility-b.png",
      "assets/categories/others-b.png",
      "assets/categories/services-b.png",
      "assets/categories/shopping-b.png",
    ];
    icons = await Future.wait(iconPathes.map(loadImage));
    drops = [];
  }

  @override
  Future<void> draw() async {
    background(color: const Color(0xFF333344));

    if (frameCount % 10 == 0) {
      final px = leakPoint.x + randomGaussian(mean: 1);
      final py = leakPoint.y.toDouble();

      drops.add(WaterDrop(px, py, this));
    }

    drops.removeWhere((e) => e.isOutdated(width, height));

    for (int i = 0; i < drops.length; i++) {
      final target = drops[i];
      for (int j = 0; j < drops.length; j++) {
        if (i != j) {
          target.applyWaterDrop(drops[j]);
        }
      }
      target.applyAnchor(PVector(114, 88), scale: 32);
      target.applyGravity(scale: 1.5);
    }

    for (final e in drops) {
      e.commit();
    }

    await image(image: bgimg1);

    await drops.map((e) => e.draw(icons)).wait;

    if (isMousePressed) {
      final mx = mouseX.toDouble() + (containerWidth - deviceWidth) / 2;
      final my = mouseY.toDouble() + (containerHeight - deviceHeight) / 2 - 72;
      final mouse = PVector(mx, my);
      fill(color: const Color(0xFFE0E0E0));
      noStroke();
      circle(
        center: mouse.toOffset(),
        diameter: 16
      );

      if (leakPoint.dist(mouse) < 16) {
        timer++;
      } else {
        timer = 0;
      }

      if (timer > 90) {
        timer = 0;
        mouse.mult(0);
        Timer(
          const Duration(milliseconds: 500),
          () {
            provider.cfpc.page = 1;
          }
        );
      }
    }

    await image(image: bgimg2);
  }

  @override
  void mousePressed() {}
}

class WaterDrop {
  late PVector p;
  late PVector v;
  late PVector a;
  late double id;
  late double id2;
  late final Sketch sketchService;

  static final _rand = Random();

  WaterDrop(double x, double y, Sketch sketch) {
    p = PVector(x, y);
    v = PVector(0, 0);
    a = PVector(0, 0);
    id = _rand.nextDouble();
    id2 = _rand.nextDouble();
    sketchService = sketch;
  }

  Future<void> draw(List<PImage> icons) async {
    final iconIdx = (id * icons.length).floor();

    if (id2 < 0.98) {
      sketchService.fill(color: Colors.lightBlue);
      sketchService.noStroke();

      sketchService.circle(
        center: p.toOffset(),
        diameter: 4,
      );
    } else {
      final icon = icons[iconIdx];
      const iconHeight = 24.0;
      final iconWidth = iconHeight / icon.height * icon.width;

      await sketchService.image(
        image: icon,
        origin: p.toOffset() - Offset(iconWidth / 2, 8.0),
        width: iconWidth,
        height: iconHeight,
      );
    }
  }

  void commit() {
    p += v * 0.0167;
    v += a * 0.0167;
    a.mult(0);
  }

  void applyWaterDrop(WaterDrop w, {double scale=1.0}) {
    final wp = w.p;
    final d = sketchService.constrain(p.dist(wp), 0.1, 16);
    final fMag = log(d + 0) / (1 * pow(d, 2)) - 2 / (exp(d) + exp(-d));
    final fUnit = wp - p + PVector(0, 0.01);

    fUnit.normalize();
    a += fUnit * fMag * scale;
  }

  void applyGravity({double scale=1.0}) {
    a += PVector(0, 9.8) * scale;
  }

  void applyAnchor(PVector anchor, {double scale=1.0}) {
    final d = sketchService.constrain(p.dist(anchor), 1, 16);
    final fMag = 8 / pow(d, 2);
    final fUnit = anchor - p + PVector(0, -0.01);

    fUnit.normalize();
    a += fUnit * fMag * scale;
  }

  bool isOutdated(int width, int height) {
    return p.x < 0 || p.x >= width || p.y < 0 || p.y >= height;
  }
}
