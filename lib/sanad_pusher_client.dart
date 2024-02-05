import 'dart:developer';

import 'package:sanad_pusher_client/utils.dart';

import 'sanad_pusher_client_platform_interface.dart';

class SanadPusherClient {
  get instance => SanadPusherClientPlatform.instance;

  Future<void> init({
    String apiKey   = 'key',
    String cluster  = 'eu',
    String? setHost = '192.168.0.235',
    int? setWsPort  = 6001,
    int? setWssPort,
    bool? useTLS    = false,
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
        apiKey: apiKey,
        cluster: cluster,
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
        onAuthorizer: onAuthorizer ?? Authorizer,
        onConnectionStateChange:
            onConnectionStateChange ?? _onConnectionStateChange,
        onMemberAdded: onMemberAdded ?? _onMemberAdded,
        onMemberRemoved: onMemberRemoved ?? _onMemberRemoved,
        onSubscriptionCount: onSubscriptionCount ?? _onSubscriptionCount,
        onSubscriptionError: onSubscriptionError ?? _onSubscriptionError,
        onSubscriptionSucceeded:
            onSubscriptionSucceeded ?? _onSubscriptionSucceeded);
  }

  Future<PusherChannel> _subscribe(channelName) {
    return SanadPusherClientPlatform.instance
        .subscribe(channelName: channelName);
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
}
