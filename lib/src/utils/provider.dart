import 'package:demo/src/utils/balance.dart';
import 'package:demo/src/utils/sensors.dart';
import 'package:flutter/material.dart';

class StateProvider {
  late final PageController pc;
  late final BalanceService balance;
  late final SensorsService sensors;
  static final _instance = StateProvider._new();

  StateProvider._new() {
    pc = PageController();
    balance = BalanceService();
    sensors = SensorsService();
  }

  factory StateProvider() => _instance;
}