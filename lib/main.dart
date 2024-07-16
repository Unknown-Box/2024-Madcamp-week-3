import 'package:demo/src/utils/provider.dart';
import 'package:demo/src/views/visual_balance.dart';
import 'package:demo/src/views/visual_leak.dart';

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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // colorScheme: const ColorScheme.light(),
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
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFE0E0E0)
        ),
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
            horizontal: 24
          ),
          child: Stack(
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
                    // physics: const NeverScrollableScrollPhysics(),
                    controller: provider.pc,
                    children: [
                      const VisualBalance(),
                      const VisualLeak(),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await provider.pc.previousPage(
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeInOut
                            );
                            await provider.pc.previousPage(
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeInOut
                            );
                          },
                          child: const Text('prev'),
                        ),
                      )
                    ],
                  )
                ),
              ),
              const Column(
                verticalDirection: VerticalDirection.up,
                children: [
                  NewWidget()
                ]
              ),
            ],
          ),
        ),
      ),
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
