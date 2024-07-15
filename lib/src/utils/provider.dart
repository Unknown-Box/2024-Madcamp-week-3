import 'package:demo/src/utils/balance.dart';
import 'package:demo/src/utils/sensors.dart';

class StateProvider {
  late final BalanceService balance;
  late final SensorsService sensors;
  static final _instance = StateProvider._new();

  StateProvider._new() {
    balance = BalanceService();
    sensors = SensorsService();
  }

  factory StateProvider() => _instance;
}