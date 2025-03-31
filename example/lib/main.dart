import 'package:flutter/material.dart';
import 'package:keyboard_notification/keyboard_notification.dart';
import 'package:keyboard_notification_example/keyboard_animation_builder.dart';

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

  final scrollController = ScrollController(keepScrollOffset: false);

  @override
  void initState() {
    super.initState();
    // observer.setCurvePrecision(0.02);
    // observer.addListener(onKeyboardNotification);
    focusNode.addListener(onFocusChange);
  }

  @override
  void dispose() {
    observer.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void onKeyboardNotification(KeyboardNotification note) {
    // print('Received note: $note');
    if (note is KeyboardAnimationStartNotification) {
      // final keyboardOverlapping =
      //     note.height -
      //     (MediaQuery.of(context).size.height - getCurrentRect().bottom);
      // print('BOTTOM: ${MediaQuery.of(context).padding.bottom}');
      // print('media query: ${MediaQuery.of(context)}');

      //
      // final newValue = note.visible ? 150.0 : 0.0;

      // scrollController.attach(ScrollPosition(physics: scrollController.position.physics))

      // print(
      //   'SCROLL ${scrollController.position.pixels} => ${newValue} (${scrollController.position.maxScrollExtent} ${scrollController.position.viewportDimension})',
      // );

      // scrollController.position.animateTo(
      //   150,
      //   duration: note.duration,
      //   curve: note.curve,
      // );

      // setState(() {
      //   curve = note.curve;
      //   duration = note.duration;
      //   position += note.visible ? -note.height : note.height;
      // });
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

  double lastKeyboardHeight = 0.0;

  @override
  Widget build(BuildContext context) {
    final rect = getCurrentRect();
    if (!positionInitialized && rect.size.height > 0) {
      positionInitialized = true;
      position = getCurrentRect().height - rowHeight;
      //   bottom = getCurrentRect().bottom;
      //   print('Position: $position, bottom = ${getCurrentRect()}');
    }
    // print(
    //   'Query: ${MediaQuery.of(context).viewPadding} + ${MediaQuery.of(context).padding}',
    // );

    // return Row(
    //   children: [
    //     Expanded(
    //       child: SingleChildScrollView(
    //         child: Column(
    //           children: [
    //             Column(
    //               children: [
    //                 SizedBox(height: MediaQuery.of(context).size.height / 2),
    //                 Padding(
    //                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //                   child: TextField(
    //                     // focusNode: focusNode,
    //                     decoration: InputDecoration(
    //                       labelText: "Enter something",
    //                     ),
    //                   ),
    //                 ),
    //                 SizedBox(height: 20),
    //                 _DemoRow(
    //                   text: 'Bottom inset',
    //                   color: Colors.blue,
    //                   right: true,
    //                   height: rowHeight,
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //     Expanded(
    //       child: SingleChildScrollView(
    //         controller: scrollController,
    //         child: KeyboardAnimationBuilder(
    //           onChange: (animation) {
    //             if (animation != null) {
    //               if (animation.isOpening) {
    //                 final target = 150 * animation.progress;
    //                 scrollController.position.jumpTo(target);
    //                 print(
    //                   'Target = $target vs ${scrollController.position.pixels}',
    //                 );
    //               } else {
    //                 scrollController.position.jumpTo(
    //                   max(
    //                     150 * (1 - animation.progress),
    //                     scrollController.position.minScrollExtent,
    //                   ),
    //                 );
    //               }
    //             }
    //             // print('Keyboard animation: ${animation}');
    //           },
    //           // builder: (context, animation, child) {
    //           //   if (animation != null) {
    //           //     if (animation.isOpening) {
    //           //       scrollController.position.jumpTo(150 * animation.progress);
    //           //     } else {
    //           //       scrollController.position.jumpTo(
    //           //         150 * (1 - animation.progress),
    //           //       );
    //           //     }
    //           //   }
    //           //   print('Keyboard animation: ${animation}');
    //           //   return child!;
    //           // },
    //           child: Column(
    //             children: [
    //               Column(
    //                 children: [
    //                   SizedBox(height: MediaQuery.of(context).size.height / 2),
    //                   SizedBox(height: 150),
    //                   Padding(
    //                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //                     child: TextField(
    //                       // focusNode: focusNode,
    //                       decoration: InputDecoration(
    //                         labelText: "Enter something",
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(height: 20),
    //                   _DemoRow(
    //                     text: 'Bottom inset',
    //                     color: Colors.blue,
    //                     right: true,
    //                     height: rowHeight,
    //                   ),
    //                   SizedBox(height: 200),
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );

    // final totalHeight = View.of(context).viewInsets
    // print('Total height: ${WidgetsBinding.instance.window.physicalSize}');

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
          KeyboardAnimationBuilder(
            key: ValueKey('Animated!'),
            builder: (context, animation, child) {
              // print(
              //   'Position: ${position}, animation?.height=  ${animation?.height}',
              // );
              if (animation != null) {
                lastKeyboardHeight = animation.height;
              }
              return Positioned(
                left: 0,
                right: 0,
                top: position - (animation?.height ?? lastKeyboardHeight),
                child: _DemoRow(
                  text: 'Keyboard Notification',
                  color: Colors.purple,
                  right: false,
                  height: rowHeight,
                ),
              );
            },
          ),
        ],
      ),
    );
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
