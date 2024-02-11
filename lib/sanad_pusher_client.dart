// import 'dart:convert';
import 'dart:developer';

import 'package:sanad_pusher_client/utils.dart';

import 'sanad_pusher_client_platform_interface.dart';

class SanadPusherClient {
  final String authUrl;
  final String appCluster;
  final String appKey;
  final String appSecret;
  final String appHost;
  final int appPort;

  SanadPusherClient({
    required this.authUrl,
    required this.appCluster,
    required this.appHost,
    required this.appKey,
    required this.appSecret,
    required this.appPort,
  });

  Future<void> initClient({
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
      setHost: setHost ?? appHost,
      setWsPort: setWsPort ?? appPort,
      setWssPort: setWssPort ?? appPort,
      useTLS: useTLS,
      pongTimeout: pongTimeout,
      maxReconnectionAttempts: maxReconnectionAttempts,
      maxReconnectGapInSeconds: maxReconnectGapInSeconds,
      activityTimeout: activityTimeout,
      onDecryptionFailure: onDecryptionFailure,
      onEvent: onEvent,
      onError: onError,
      onAuthorizer: onAuthorizer,
      onConnectionStateChange: onConnectionStateChange,
      onMemberAdded: onMemberAdded,
      onMemberRemoved: onMemberRemoved,
      onSubscriptionCount: onSubscriptionCount,
      onSubscriptionError: onSubscriptionError,
      onSubscriptionSucceeded: onSubscriptionSucceeded,
      proxy: proxy,
    );
  }

  SanadPusherClientPlatform get instance => SanadPusherClientPlatform.instance;

  Future<void> connect() async {
    return instance.connect();
  }

  Future<void> trigger(PusherEvent event) async {
    // String ch = event.channelName;
    // PusherChannel? channel = instance.getChannel(event.channelName);
    if (instance.connectionState == instance.disConnected) {
      await instance.connect();
      return;
    }
    try{
    instance.trigger(event);

    }catch (e){
      log(e.toString());
    }
  }

  Future<PusherChannel> subscribe(
    channelName, {
    var onEvent,
    var onMemberAdded,
    var onMemberRemoved,
    var onSubscriptionCount,
    var onSubscriptionError,
    var onSubscriptionSucceeded,
  }) {
    return instance.subscribe(
        channelName: channelName,
        onEvent: onEvent,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        onSubscriptionCount: onSubscriptionCount,
        onSubscriptionError: onSubscriptionError,
        onSubscriptionSucceeded: onSubscriptionSucceeded);
  }

  // initLocationChannel() async {
  //   _locationChannel = PusherChannel(
  //       channelName: locationChannelName, me: PusherMember(_userId, {}));

  //   locationEvent = PusherEvent(
  //     channelName:
  //       locationChannelName.startsWith("presence-")
  //         ? locationChannelName:'presence-$locationChannelName',
  //     eventName: 'client-GPS-update',
  //     userId: _userId,
  //   );
  //   // await join(_locationChannel.channelName);
  //   // await connect();
  // }

  // void setCredentials(
  //     String userId, String companyId, String token, String userEmail) {
  //   _userEmail = userEmail;
  //   _userId = userId;
  //   _companyId = companyId;
  //   _token = token;
  //   initLocationChannel();
  // }

  // Future<PusherChannel> join(channelName, {var onEvent}) {
  //   channelName = 'presence-$channelName';
  //   return _subscribe(channelName);
  // }

  // Future<PusherChannel> private(channelName) {
  //   channelName = 'private-$channelName';
  //   return _subscribe(channelName);
  // }

  // Future<PusherChannel> channel(channelName) {
  //   return _subscribe(channelName);
  // }

  // Future<void> updateLocation(var lat, var lng) async {
  //   trigger(locationEvent.copyWith(
  //       data:jsonEncode( {'id': _userId, 'lat': lat, 'lng': lng, 'email': _userEmail})));
  // }
}
