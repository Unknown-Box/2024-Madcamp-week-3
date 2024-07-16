import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

class VisualLeak extends StatelessWidget {
  const VisualLeak({ super.key });

  @override
  Widget build(BuildContext context) {
    return Processing(sketch: LeakIndicator(
      containerWidth: 256,
      containerHeight: 256,
    ));
  }
}

class LeakIndicator extends Sketch {
  final int containerWidth;
  final int containerHeight;

  late final PImage bgimg1;
  late final PImage bgimg2;
  late final List<PImage> icons;
  late final List<WaterDrop> drops;

  LeakIndicator({
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Future<void> setup() async {
    frameRate = 60;
    size(width: containerWidth, height: containerHeight);
    background(color: const Color(0xFF333344));

    bgimg1 = await loadImage('assets/b1b.png');
    bgimg2 = await loadImage('assets/b2.png');

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
      final px = 104 + randomGaussian(mean: 1);
      final py = 88.0;

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

    // final clusters = WaterCluster.fromWaterDrops(
    //   drops: drops,
    //   sketch: this
    // );

    await image(image: bgimg1);

    // circle(
    //   center: Offset(114, 88),
    //   diameter: 16,
    // );

    // for (final e in drops) {
    //   e.draw(icons);
    // }

    await drops.map((e) => e.draw(icons)).wait;

    await image(image: bgimg2);
  }
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

// class WaterCluster {
//   final List<WaterDrop> drops;
//   final Sketch sketchService;

//   const WaterCluster({
//     required this.drops,
//     required this.sketchService,
//   });

//   void draw() {
//     sketchService.fill(color: Colors.lightBlue);
//     sketchService.stroke(color: Colors.black);
//     sketchService.noStroke();

//     // final size = drops.length;
//     // sketchService.circle(
//     //   center: drops.last.p.toOffset(),
//     //   diameter: 4 * sqrt(size)
//     // );

//     for (final e in drops) {
//       sketchService.circle(
//         center: e.p.toOffset(),
//         diameter: 4,
//       );
//     }
//   }

//   static List<WaterCluster> fromWaterDrops({
//     required List<WaterDrop> drops,
//     required Sketch sketch
//   }) {
//     final cids = List.generate(drops.length, (i) => i);

//     int getRoot(int i) {
//       if (i == cids[i]) {
//         return i;
//       } else {
//         return cids[i] = getRoot(cids[i]);
//       }
//     }

//     for (int i = 0; i < drops.length; i++) {
//       for (int j = i+1; j < drops.length; j++) {
//         if (drops[i].p.dist(drops[j].p) < 4) {
//           final rootI = getRoot(i);
//           final rootJ = getRoot(j);

//           if (rootI < rootJ) {
//             cids[rootJ] = rootI;
//           } else {
//             cids[rootI] = rootJ;
//           }
//         }
//       }
//     }

//     return List
//       .generate(drops.length, (i) => i)
//       .fold<Map<int, List<int>>>({}, (clusters, int i) {
//         final cid = cids[i];
//         if (clusters.containsKey(cid)) {
//           clusters[cid]!.add(i);
//         } else {
//           clusters[cid] = [i];
//         }

//         return clusters;
//       })
//       .values
//       .map((e) => WaterCluster(
//         drops: e.map((i) => drops[i]).toList(),
//         sketchService: sketch,
//       ))
//       .toList();
//   }
// }
