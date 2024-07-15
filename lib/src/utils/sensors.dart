import 'package:sensors/sensors.dart';

class SensorsService {
  late double ax, ay;

  static final _instance = SensorsService._new();

  SensorsService._new() {
    ax = 0.0;
    ay = 9.8;

    accelerometerEvents.listen((e) {
      ax = e.x;
      ay = e.y;
    });
  }

  factory SensorsService() => _instance;
}
