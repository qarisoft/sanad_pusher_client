import 'dart:async';
import 'dart:convert';
import 'dart:developer';
// import 'dart:html';

import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:sanad_pusher_client/sanad_pusher_client.dart';
import 'package:sanad_pusher_client/utils.dart';
// import 'package:sanad_pusher_client/sanad_pusher_client_platform_interface.dart';
// import 'package:sanad_pusher_client/utils.dart';

// import 'package:sanad_pusher_client/utils.dart';

class PusherClient {
  final String appCluster = 'eu';
  final String appKey = 'key';
  final String appSecret = 'sec';
  final String authUrl = 'http://192.168.0.235:8001/api/broadcasting/auth';
  final String appHost = '192.168.0.235';
  final int appPort = 6001;
  AuthUser? _user;
  late SanadPusherClient pusher;
  final String presence = 'presence';
  final String private = 'private';

  PusherLocation location = PusherLocation();
  StreamController<String> connectionState = StreamController<String>();
  PusherClient() {
    pusher = SanadPusherClient(
        authUrl: authUrl,
        appCluster: appCluster,
        appHost: appHost,
        appKey: appKey,
        appSecret: appSecret,
        appPort: appPort);
  }

  String get locationChannelName =>
      '$presence-location-channel.${user?.companyId}';

  Future<void> init() async {
    log('init started ');
    if (_user == null) {
      log('user is null ');

      user = await getUser();
      log('after getUser()');
    }

    await pusher.initClient(
      onDecryptionFailure: onDecryptionFailure,
      // onEvent: onEvent,
      useTLS: false,
      onError: onError,
      onAuthorizer: onAuthorizer,
      onConnectionStateChange: onConnectionStateChange,
      // onMemberAdded: onMemberAdded,
      // onMemberRemoved: onMemberRemoved,
      onSubscriptionCount: onSubscriptionCount,
      onSubscriptionError: onSubscriptionError,
      onSubscriptionSucceeded: onSubscriptionSucceeded,
    );
    await pusher.connect();
    log('pusher connect');
    if (user == null) {
      log('user is still null');
      return;
    }
    await initLocationChannel();
  }

  initLocationChannel() async {
    await pusher.subscribe(locationChannelName);
    log('pusher.instance.connectionState ${pusher.instance.connectionState}');

    location.locationStream.listen((event) {
      log('updating location ${event.toString()}');

      pusher.trigger(
        PusherEvent(
            channelName: locationChannelName,
            eventName: 'client-GPS-change',
            data: {
              'lat': event.latitude,
              'long': event.longitude,
              'id': user?.id,
              'email': user?.email
            },
            userId: user?.id),
      );
    });
  }

  set user(AuthUser? userData) {
    _user = userData!;
  }

  AuthUser? get user => _user;

  dynamic onAuthorizer(
      String channelName, String socketId, dynamic options) async {
    var result = await http.post(
      Uri.parse(authUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${user?.token}',
      },
      body: 'socket_id=$socketId&channel_name=$channelName',
    );
    var json = jsonDecode(result.body);
    log(json.toString());

    return json;
  }

  // void _onEvent(PusherEvent event) {
  //   log("onEvent: $event");
  // }
  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    log("Connection: $currentState");
    pusher.instance.connectionState = currentState;
    connectionState.sink.add(currentState);
  }

  void onError(String message, int? code, dynamic e) {
    log("onError: $message code: $code exception: $e");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("onSubscriptionSucceeded: $channelName data: $data");
    final me = pusher.instance.getChannel(channelName)?.me;
    log("Me: $me");
  }

  void onSubscriptionError(String message, dynamic e) {
    log("onSubscriptionError: $message Exception: $e");
  }

  void onDecryptionFailure(String event, String reason) {
    log("onDecryptionFailure: $event reason: $reason");
  }

  void onSubscriptionCount(String channelName, int subscriptionCount) {
    log("onSubscriptionCount: $channelName subscriptionCount: $subscriptionCount");
  }
}

class AuthUser {
  final String id;
  final String token;
  final String companyId;
  final String email;
  String? companyName;

  AuthUser(
      {required this.id,
      required this.token,
      required this.companyId,
      required this.email});

  @override
  String toString() {
    return 'AuthUser(id: $id, token: $token, companyId: $companyId, email: $email)';
  }
}

class PusherLocation {
  // String? connection = 'not connected';
  Location location = Location();
  StreamController<String> connection = StreamController<String>();
  Stream<String> get connectionStream => connection.stream;
  Stream<LocationData> get locationStream => location.onLocationChanged;
  StreamSink<String> get sink => connection.sink;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData locationData;

  PusherLocation() {
    initLocation();
  }

  initLocation() async {
    await _getLocationService();
    await _getLocationPermeation();
    await location.enableBackgroundMode();
  }

  Future<bool> _getLocationService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return Future.error('error');
      }
    }
    return _serviceEnabled;
  }

  Future<PermissionStatus> _getLocationPermeation() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return Future.error('error');
      }
    }
    return _permissionGranted;
  }
}
// void onMemberAdded(String channelName, PusherMember member) {
//   log("onMemberAdded: $channelName user: $member");
// }

// void _onMemberRemoved(String channelName, PusherMember member) {
//   log("onMemberRemoved: $channelName user: $member");
// }

Future<AuthUser> getUser(
    {email = 'salah@t.t',
    password = 'password',
    authUrl = 'http://192.168.0.235:8001/api/login'}) async {
  log('getUser started ');
  try {
    var headers = {'Accept': 'application/json'};
    var request = http.MultipartRequest('POST', Uri.parse(authUrl));
    request.fields.addAll({'email': email, 'password': password});

    request.headers.addAll(headers);
    log('request.headers.addAll(headers);');
    http.StreamedResponse response =
        await request.send().timeout(const Duration(seconds: 5));
    log('http.StreamedResponse response = await request.send();');

    if (response.statusCode == 200) {
      String authData = await response.stream.bytesToString();
      var authJs = jsonDecode(authData);
      String companyId = authJs['company']['id'].toString();
      String userId = authJs['user']['id'].toString();
      String userEmail = authJs['user']['email'].toString();
      String token = authJs['token'].toString();
      AuthUser user = AuthUser(
        id: userId,
        token: token,
        companyId: companyId,
        email: userEmail,
      );
      return user;
    } else {
      log('can\'t get to the server ${response.statusCode}');
      return Future.error('error');
    }
  } catch (e) {
    log("ERROR: $e");
    return Future.error(e.toString());
  }
}
