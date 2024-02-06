import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:sanad_pusher_client/utils.dart';

import 'sanad_pusher_client_platform_interface.dart';

class SanadPusherClient {
  final String authUrl;
  final String token;
  String appKey;
  String appSecret;
  final String appCluster;
  String host;
  int port;
  SanadPusherClient(
      {required this.authUrl,
      required this.token,
      required this.appCluster,
      required this.host,
      required this.appKey,
      required this.appSecret,
      required this.port}) {
    init();
  }
  get instance => SanadPusherClientPlatform.instance;

  Future<void> init({
    String? apiKey,
    String? cluster,
    String? setHost,
    int? setWsPort,
    int? setWssPort,
    bool? useTLS = false,
    int? activityTimeout,
    int? pongTimeout,
    int? maxReconnectionAttempts,
    int? maxReconnectGapInSeconds,
    String? proxy, // pusher-websocket-java only
    Function(String currentState, String previousState)?
        onConnectionStateChange,
    Function(String channelName, dynamic data)? onSubscriptionSucceeded,
    Function(String message, dynamic error)? onSubscriptionError,
    Function(String event, String reason)? onDecryptionFailure,
    Function(String message, int? code, dynamic error)? onError,
    Function(PusherEvent event)? onEvent,
    Function(String channelName, PusherMember member)? onMemberAdded,
    Function(String channelName, PusherMember member)? onMemberRemoved,
    Function(String channelName, String socketId, dynamic options)?
        onAuthorizer,
    Function(String channelName, int subscriptionCount)? onSubscriptionCount,
  }) async {
    return SanadPusherClientPlatform.instance.init(
        apiKey: apiKey ?? appKey,
        cluster: cluster ?? appCluster,
        setHost: setHost,
        setWsPort: setWsPort,
        setWssPort: setWssPort,
        useTLS: useTLS,
        pongTimeout: pongTimeout,
        maxReconnectionAttempts: maxReconnectionAttempts,
        maxReconnectGapInSeconds: maxReconnectGapInSeconds,
        activityTimeout: activityTimeout,
        onDecryptionFailure: onDecryptionFailure ?? _onDecryptionFailure,
        onEvent: onEvent ?? _onEvent,
        onError: onError ?? _onError,
        onAuthorizer: onAuthorizer ?? _onAuthorizer,
        onConnectionStateChange:
            onConnectionStateChange ?? _onConnectionStateChange,
        onMemberAdded: onMemberAdded ?? _onMemberAdded,
        onMemberRemoved: onMemberRemoved ?? _onMemberRemoved,
        onSubscriptionCount: onSubscriptionCount ?? _onSubscriptionCount,
        onSubscriptionError: onSubscriptionError ?? _onSubscriptionError,
        onSubscriptionSucceeded:
            onSubscriptionSucceeded ?? _onSubscriptionSucceeded);
  }

  Future<void> connect() async {
    return SanadPusherClientPlatform.instance.connect();
  }

  Future<PusherChannel> join(channelName) {
    channelName = 'presence-$channelName';
    return _subscribe(channelName);
  }

  Future<PusherChannel> private(channelName) {
    channelName = 'private-$channelName';
    return _subscribe(channelName);
  }

  Future<PusherChannel> channel(channelName) {
    return _subscribe(channelName);
  }

  trigger(PusherEvent event) {
    SanadPusherClientPlatform.instance.trigger(event);
  }

  Future<PusherChannel> _subscribe(channelName) {
    return SanadPusherClientPlatform.instance
        .subscribe(channelName: channelName);
  }

  void _onConnectionStateChange(dynamic currentState, dynamic previousState) {
    log("Connection: $currentState");
  }

  void _onError(String message, int? code, dynamic e) {
    log("onError: $message code: $code exception: $e");
  }

  void _onEvent(PusherEvent event) {
    log("onEvent: $event");
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    log("onSubscriptionSucceeded: $channelName data: $data");
    final me = SanadPusherClientPlatform.instance.getChannel(channelName)?.me;
    log("Me: $me");
  }

  void _onSubscriptionError(String message, dynamic e) {
    log("onSubscriptionError: $message Exception: $e");
  }

  void _onDecryptionFailure(String event, String reason) {
    log("onDecryptionFailure: $event reason: $reason");
  }

  void _onMemberAdded(String channelName, PusherMember member) {
    log("onMemberAdded: $channelName user: $member");
  }

  void _onMemberRemoved(String channelName, PusherMember member) {
    log("onMemberRemoved: $channelName user: $member");
  }

  void _onSubscriptionCount(String channelName, int subscriptionCount) {
    log("onSubscriptionCount: $channelName subscriptionCount: $subscriptionCount");
  }

  dynamic _onAuthorizer(String channelName, String socketId, dynamic options,
      [authUrl = 'http://192.168.0.235:8000/api/broadcasting/auth',
      String token =
          "2|yxfhvJjork9HnnxL6y0jF4JXyIJxbJdRoge3clq1381f054e"]) async {
    // var authUrl = ;
    var result = await http.post(
      Uri.parse(authUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: 'socket_id=$socketId&channel_name=$channelName',
    );
    var json = jsonDecode(result.body);
    return json;
  }
}
