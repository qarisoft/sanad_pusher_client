import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:sanad_pusher_client/utils.dart';

import 'sanad_pusher_client_platform_interface.dart';

class SanadPusherClient {
  final String authUrl;
  final String appCluster;
  final String appKey;
  final String appSecret;
  final String host;
  final int port;

  late PusherChannel _locationChannel;
  late String locationChannelName;
  late String _token;
  late String _userId;
  late String _userEmail;
  late String _companyId;
  late PusherEvent locationEvent;

  SanadPusherClient({
    required this.authUrl,
    // this.token,
    required this.appCluster,
    required this.host,
    required this.appKey,
    required this.appSecret,
    required this.port,
    this.locationChannelName = 'location-channel',
  }) {
    _initClient();
    // connect();
  }
  SanadPusherClientPlatform get instance => SanadPusherClientPlatform.instance;
  get locationChannel {
    return _locationChannel;
  }

  Future<void> connect() async {
    return instance.connect();
  }

  void setCredentials(userId, companyId, token, userEmail) {
    _userEmail = userEmail;
    _userId = userId;
    _companyId = companyId;
    _token = token;
    _initLocationChannel();
  }

  Future<PusherChannel> join(channelName, {var onEvent}) {
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

  Future<void> updateLocation(var lat, var lng) async {
    trigger(locationEvent.copyWith(data: {'id':_userId, 'lat': lat, 'lng': lng, 'email':_userEmail}));
  }

  Future<PusherChannel> _subscribe(
    channelName, {
    var onEvent,
    var onMemberAdded,
    var onMemberRemoved,
    var onSubscriptionCount,
    var onSubscriptionError,
    var onSubscriptionSucceeded,
  }) {
    if (_companyId.isEmpty ||
        _userEmail.isEmpty ||
        _companyId.isEmpty ||
        _token.isEmpty) {
      return Future.error('you must set credentials first');
    }

    return instance.subscribe(
        channelName: channelName,
        onEvent: onEvent,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        onSubscriptionCount: onSubscriptionCount,
        onSubscriptionError: onSubscriptionError,
        onSubscriptionSucceeded: onSubscriptionSucceeded);
  }

  _initLocationChannel() {
    _locationChannel = PusherChannel.presence(
        channelName: locationChannelName, me: PusherMember(_userId, {}));
    locationEvent = PusherEvent(
      channelName: '$locationChannelName$_companyId',
      eventName: 'client-GPS-update',
      userId: _userId,
    );
    join(_locationChannel.channelName);
  }

  Future<void> _initClient({
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
      // if (_token==null){
      //   return ;
      // }
      String channelName,
      String socketId,
      dynamic options) async {
    var result = await http.post(
      Uri.parse(authUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: 'socket_id=$socketId&channel_name=$channelName',
    );
    var json = jsonDecode(result.body);
    return json;
  }
}
