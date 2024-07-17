import 'package:demo/src/common/crossfade_pageview.dart';
import 'package:demo/src/utils/provider.dart';
import 'package:demo/src/views/radarpie.dart';
import 'package:demo/src/views/visual_balance.dart';
import 'package:demo/src/views/visual_leak.dart';
import 'package:demo/src/views/wordcloud.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // colorScheme: const ColorScheme.light(),
        fontFamily: 'KoPubDotum',
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
  final provider = StateProvider();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 0
          ),
          child: Stack(
            children: [
              CrossfadePageview(
                controller: provider.cfpc,
                children: [
                  Center(
                    child: Container(
                      width: 256,
                      height: 256,
                      decoration: const BoxDecoration(
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
                      child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: provider.pc,
                        children: const [
                          VisualBalance(),
                          VisualLeak(),
                          // Center(
                          //   child: ElevatedButton(
                          //     onPressed: () async {
                          //       await provider.pc.previousPage(
                          //         duration: const Duration(seconds: 1),
                          //         curve: Curves.easeInOut
                          //       );
                          //       await provider.pc.previousPage(
                          //         duration: const Duration(seconds: 1),
                          //         curve: Curves.easeInOut
                          //       );
                          //     },
                          //     child: const Text('prev'),
                          //   ),
                          // ),
                        ],
                      )
                    ),
                  ),
                  const ExpenditureRadarChart(),
                  const ExpenditureWordCloud(),
                ]
              ),
              NewWidget2(provider: provider),
              // Column(
              //   verticalDirection: VerticalDirection.up,
              //   children: [
              //     const SizedBox(height: 64),
              //     const NewWidget(),
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         ElevatedButton(
              //           onPressed: () {
              //             provider.cfpc.page--;
              //           },
              //           child: const Text('prev')
              //         ),
              //         ElevatedButton(
              //           onPressed: () {
              //             provider.cfpc.page++;
              //           },
              //           child: const Text('next')
              //         ),
              //       ],
              //     )
              //   ]
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewWidget2 extends StatefulWidget {
  const NewWidget2({
    super.key,
    required this.provider,
  });

  final StateProvider provider;

  @override
  State<NewWidget2> createState() => _NewWidget2State();
}

class _NewWidget2State extends State<NewWidget2> {
  bool flag = false;

  @override
  Widget build(BuildContext context) {
    void f() {
      setState(() {
        flag = !flag;
      });
    }
    widget.provider.handler = f;
    return Align(
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          (widget.provider.pc.page ?? 0.0) > 0.1
          ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (widget.provider.cfpc.page == 0) {
                if (widget.provider.pc.page == 1.0) {
                  await widget.provider.pc.previousPage(
                    duration: const Duration(seconds: 1),
                    curve: Curves.ease
                  );
                }
              } else if (widget.provider.cfpc.page == 1) {
                widget.provider.cfpc.page = 0;
              } else {
                widget.provider.cfpc.page = 1;
              }
              f();
            },
            color: const Color(0xFFE0E0E0),
          )
          : const SizedBox.shrink(),
          (widget.provider.pc.page ?? 0.0) > 0.1
          && (widget.provider.cfpc.page == 1)
          ? IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () async {
              widget.provider.cfpc.page = 2;
              f();
            },
            color: const Color(0xFFE0E0E0),
          )
          : const SizedBox.shrink(),
        ],
      )
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
