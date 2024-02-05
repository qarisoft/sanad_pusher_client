import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sanad_pusher_client/sanad_pusher_client.dart';
import 'package:sanad_pusher_client/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String currentState = '';
  String previousState = '';
  List<String> data = ['dasdasdas', 'dsadasd'];
  final _sanadPusherClientPlugin = SanadPusherClient();

  @override
  void initState() {
    log('message');
    super.initState();
    // initPlatformState();
  }

  onConnectionStateChange(String current, String previous) {
    setState(() {
      previousState = previous;
      currentState = current;
    });
  }

  onEvent(PusherEvent event) {
    setState(() {
      log(event.isNotRegular().toString());
      if (event.isNotRegular()) data.add(event.data);
      // data.add(event.toString());
    });
    log(event.eventName.toString());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    try {
      await _sanadPusherClientPlugin.init(
          onConnectionStateChange: onConnectionStateChange, onEvent: onEvent);
      await _sanadPusherClientPlugin.join('chat.1');
      await _sanadPusherClientPlugin.connect();
    } catch (e) {
      log("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data.toString()),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        onPressed: () => {
                          initPlatformState()
                        },
                        child: const Text('connect'),
                      ),
                      FloatingActionButton(
                          onPressed: () => {}, child: const Text('triger'))
                    ],
                  )),
            )
          ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => initPlatformState(),
        // ),
      ),
    );
  }
}
