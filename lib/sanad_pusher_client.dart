import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:sanad_pusher_client/utils.dart';

import 'sanad_pusher_client_platform_interface.dart';

class SanadPusherClient {
  final String authUrl;
  final String token;
  final String appCluster;
  final String appKey;
  final String appSecret;
  final String host;
  final int port;
  final PusherChannel _locationChannel;
  String locationChannelName;
  String userId;
  String companyId;
  PusherEvent locationEvent;

  SanadPusherClient(
      {required this.authUrl,
      required this.token,
      required this.appCluster,
      required this.host,
      required this.appKey,
      required this.appSecret,
      required this.port,
      this.locationChannelName = 'location-channel.',
      required this.userId,
      required this.companyId})
      : _locationChannel = PusherChannel.presence(
            channelName: locationChannelName, me: PusherMember(userId, {})),
        locationEvent = PusherEvent(
          channelName: '$locationChannelName$companyId',
          eventName: 'client-GPS-update',
          userId: userId,
        ) {
    init();
    // connect();
  }
  get instance => SanadPusherClientPlatform.instance;
  get locationChannel {
    return _locationChannel;
  }

  Future<void> connect() async {
    return instance.connect();
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

  Future<void> trigger(PusherEvent event) async {
    instance.trigger(event);
  }

  Future<void> init({
    String? apiKey,
    String? cluster,
    String? setHost,
    int? setWsPort,
    int? setWssPort,
    bool? useTLS,
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
    return instance.init(
        apiKey: apiKey ?? appKey,
        cluster: cluster ?? appCluster,
        setHost: setHost ?? host,
        setWsPort: setWsPort ?? port,
        setWssPort: setWssPort ?? port,
        useTLS: useTLS ?? false,
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

  Future<void> updateLocation(var lat, var lng) async {
    trigger(locationEvent.copyWith(data: {lat: lat, lng: lng}));
  }

  Future<PusherChannel> _subscribe(channelName) {
    return instance.subscribe(channelName: channelName);
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
    final me = instance.getChannel(channelName)?.me;
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

  dynamic _onAuthorizer(
      String channelName, String socketId, dynamic options) async {
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
