import 'package:flutter/material.dart';

class CrossfadePageview extends StatefulWidget {
  final List<Widget> children;
  final CrossfadePageViewController? controller;

  const CrossfadePageview({
    super.key,
    this.controller,
    required this.children,
  });

  @override
  State<CrossfadePageview> createState() => _CrossfadePageViewState();
}

class _CrossfadePageViewState extends State<CrossfadePageview> {
  bool flag = false;
  late final List<Widget> children;
  late final CrossfadePageViewController controller;

  @override
  void initState() {
    super.initState();
    children = widget.children;
    controller = widget.controller ?? CrossfadePageViewController();

    controller.handler = () {
      setState(() {
        flag = !flag;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(children.length, (i) =>
        IgnorePointer(
          ignoring: controller.page != i,
          child: AnimatedOpacity(
            curve: Curves.easeOut,
            opacity: controller.pageOpacity(i),
            duration: const Duration(milliseconds: 1500),
            child: children[i],
          ),
        )
      ),
    );
  }
}

class CrossfadePageViewController {
  int currentPage;
  late final void Function() handler;

  CrossfadePageViewController({
    this.currentPage = 0,
  });

  int get page => currentPage;
  set page(int page) {
    if (page < 0) {
      return;
    }

    currentPage = page;
    handler();
  }

  double pageOpacity(int i) => i == currentPage ? 1.0 : 0.0;
}
