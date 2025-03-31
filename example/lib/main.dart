import 'package:flutter/material.dart';
import 'package:keyboard_notification/keyboard_notification.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text('Plugin example app')),
        body: SafeArea(top: true, bottom: true, child: const MyApp()),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final observer = KeyboardObserver();
  final focusNode = FocusNode();

  static const rowHeight = 30.0;

  var positionInitialized = false;
  var bottom = 0.0;
  var position = 0.0;
  var duration = Duration(milliseconds: 0);
  var curve = Curves.linear;

  @override
  void initState() {
    super.initState();
    // KeyboardNotification.setCurvePrecision(0.05);
    observer.addListener(onKeyboardNotification);
    focusNode.addListener(onFocusChange);
  }

  @override
  void dispose() {
    observer.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void onKeyboardNotification(KeyboardNotification note) {
    print('Received note: $note');
    if (note is KeyboardAnimationStartNotification) {
      // final keyboardOverlapping =
      //     note.height -
      //     (MediaQuery.of(context).size.height - getCurrentRect().bottom);
      print('BOTTOM: ${MediaQuery.of(context).padding.bottom}');
      print('media query: ${MediaQuery.of(context)}');
      print('Total height: ${WidgetsBinding.instance.window.physicalSize}');
      setState(() {
        curve = note.curve;
        duration = note.duration;
        position += note.visible ? -note.height : note.height;
      });
    }
  }

  void onFocusChange() {
    setState(() {});
  }

  Rect getCurrentRect() {
    if (!mounted) return Rect.zero;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return Rect.zero;
    final parentPosition = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      parentPosition.dx,
      parentPosition.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rect = getCurrentRect();
    if (!positionInitialized && rect.size.height > 0) {
      positionInitialized = true;
      position = getCurrentRect().height - rowHeight;
      bottom = getCurrentRect().bottom;
      print('Position: $position, bottom = ${getCurrentRect()}');
    }
    print(
      'Query: ${MediaQuery.of(context).viewPadding} + ${MediaQuery.of(context).padding}',
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        focusNode.unfocus();
      },
      child: Stack(
        children: [
          Column(
            children: [
              focusNode.hasPrimaryFocus
                  ? const Text(
                    'Tap anywhere outside TextField to hide the keyboard',
                  )
                  : const Text('Tap on TextField below to show the keyboard'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  focusNode: focusNode,
                  decoration: InputDecoration(labelText: "Enter something"),
                ),
              ),
              Expanded(child: Container()),
              _DemoRow(
                text: 'Bottom inset',
                color: Colors.blue,
                right: true,
                height: rowHeight,
              ),
            ],
          ),
          if (positionInitialized)
            AnimatedPositioned(
              duration: duration,
              curve: curve,
              // bottom: 0,
              left: 0,
              right: 0,
              // height: rowHeight,
              top: position,
              child: _DemoRow(
                text: 'Keyboard Notification',
                color: Colors.purple,
                right: false,
                height: rowHeight,
              ),
            ),
        ],
      ),
    );
  }
}

class _ContentView extends StatefulWidget {
  const _ContentView({super.key});

  @override
  State<_ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<_ContentView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _DemoRow extends StatelessWidget {
  final String text;
  final Color color;
  final bool right;
  final double height;
  const _DemoRow({
    super.key,
    required this.text,
    required this.color,
    required this.right,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (right) Expanded(child: Container()),
        Expanded(
          child: Container(
            height: height,
            color: color,
            child: Center(
              child: Text(text, style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        if (!right) Expanded(child: Container()),
      ],
    );
  }
}
