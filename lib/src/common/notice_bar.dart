import 'dart:async';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class AnimatedSingleLineNoticeBar extends StatefulWidget {
  final List<AnimatedSingleLineNoticeBarItem> items;
  final Duration duration;
  final Duration interval;
  final Matrix4 translate;

  const AnimatedSingleLineNoticeBar({
    super.key,
    required this.items,
    required this.duration,
    required this.interval,
    required this.translate,
  });

  @override
  State<AnimatedSingleLineNoticeBar> createState() => _AnimatedSingleLineNoticeBarState();
}

class _AnimatedSingleLineNoticeBarState extends State<AnimatedSingleLineNoticeBar> {
  late Timer _timer;
  late List<double> _opacity;
  late List<Matrix4> _translate;

  late List<AnimatedSingleLineNoticeBarItem> items;

  @override
  void initState() {
    super.initState();

    late final int itemCount;
    if (widget.items.length < 3) {
      items = [...widget.items, ...widget.items, ...widget.items];
      itemCount = items.length;
    } else {
      items = widget.items;
      itemCount = items.length;
    };

    _timer = Timer.periodic(widget.interval, timerCallback);
    _opacity = [1, ...List.filled(itemCount - 1, 0)];
    _translate = [
      Matrix4.translationValues(0, 0, 0),
      ...List.filled(itemCount - 2, -widget.translate),
      widget.translate
    ];
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: IterableZip([items, _opacity, _translate]).map((zipped) =>
        AnimatedOpacity(
          opacity: zipped[1] as double,
          duration: widget.duration,
          child: AnimatedContainer(
            duration: widget.duration,
            transform: zipped[2] as Matrix4,
            child: zipped[0] as Widget
          ),
        )
      ).toList(),
    );
  }

  void timerCallback(Timer _) {
    setState(() {
      final itemCount = items.length;
      _opacity = [_opacity.last, ..._opacity.sublist(0, itemCount - 1)];
      _translate = [_translate.last, ..._translate.sublist(0, itemCount - 1)];
    });
  }
}

class AnimatedSingleLineNoticeBarItem extends StatelessWidget {
  final Widget child;

  const AnimatedSingleLineNoticeBarItem({
    super.key,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
