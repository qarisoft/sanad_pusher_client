import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:sanad_pusher_client/utils.dart';
import 'package:sanad_pusher_client_example/app.dart';

void log(var m) {
  dev.log(m.toString());
}

void main() async {
  // AuthUser user = await AuthUser.getUser();
  // log(user);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  // final AuthUser user;
  const MyApp({
    Key? key,
    // required this.user,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String currentState = 'Not Connected';
  String previousState = '';
  String locationData = '';
  //  String? _latestHardwareButtonEvent;

  // StreamSubscription<String>? _buttonSubscription;
  List<String> data = ['dasdasdas', 'dsadasd'];

  PusherClient client = PusherClient();

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

  getUser() async {
    await client.init();
    log('client ${client.user}');
    client.connectionState.stream.listen((event) {
      setState(() {
        currentState = event;
      });
    });

    client.location.locationStream.listen((event) {
      log('client.location.locationStream $event');
      setState(() {
        locationData = event.toString();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
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
            Text(currentState),
            Text(locationData),
            Text(data.toString()),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        onPressed: () {},
                        child: const Text('connect'),
                      ),
                      FloatingActionButton(
                          onPressed: () {
                            // channel?.trigger(PusherEvent(
                            //     channelName: 'presence-location-channel.1',
                            //     eventName: 'client-GPS-change',
                            //     data: {
                            //       'lat': '34324234234234sssss',
                            //       'lng': 'dd4342349830248023dddd'
                            //     }));
                          },
                          child: const Text('triger'))
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
