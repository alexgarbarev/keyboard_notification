import 'package:flutter/material.dart';
import 'package:keyboard_notification/keyboard_animated_builder.dart';

void main() {
  runApp(ExampleAnimations());
}

class ExampleAnimations extends StatelessWidget {
  const ExampleAnimations({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Keyboard Animations Example')),
        body: SafeArea(
          top: true,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onTapOutside:
                          (details) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                      decoration: InputDecoration(
                        labelText: "Tap to trigger keyboard",
                      ),
                    ),
                    Text(
                      'Screen height: ${MediaQuery.of(context).size.height}',
                    ),
                    KeyboardAnimatedBuilder(
                      builder: (context, keyboard, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keyboard:\n\t\theight: ${keyboard.height}\n\t\ttotal height: ${keyboard.totalHeight}',
                            ),
                            Text(
                              '\t\tvisibility: ${keyboard.visibility}',
                              semanticsLabel: 'visibility',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                KeyboardAnimatedBuilder(
                  builder: (context, keyboard, child) {
                    return Positioned(
                      bottom: (keyboard.totalHeight + 20) * keyboard.visibility,
                      left: 0,
                      right: 0,
                      child: Opacity(
                        opacity: keyboard.visibility,
                        child: Container(
                          height: 40,
                          color: Colors.lightBlueAccent,
                          child: Center(child: Text('Toolbar')),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
