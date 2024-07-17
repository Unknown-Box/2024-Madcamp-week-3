import 'package:demo/src/common/crossfade_pageview.dart';
import 'package:demo/src/utils/balance.dart';
import 'package:demo/src/utils/sensors.dart';
import 'package:flutter/material.dart';

class StateProvider {
  late final PageController pc;
  late final CrossfadePageViewController cfpc;
  late final BalanceService balance;
  late final SensorsService sensors;

  void Function()? handler;

  static final _instance = StateProvider._new();

  StateProvider._new() {
    pc = PageController();
    cfpc = CrossfadePageViewController();
    balance = BalanceService();
    sensors = SensorsService();
  }

  factory StateProvider() => _instance;
}