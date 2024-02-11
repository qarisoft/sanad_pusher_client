import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sanad_pusher_client/utils.dart';

import 'sanad_pusher_client_method_channel.dart';

abstract class SanadPusherClientPlatform extends PlatformInterface {
  /// Constructs a SanadPusherClientPlatform.
  SanadPusherClientPlatform() : super(token: _token);

  static final Object _token = Object();

  static SanadPusherClientPlatform _instance = MethodChannelSanadPusherClient();

  /// The default instance of [SanadPusherClientPlatform] to use.
  ///
  /// Defaults to [MethodChannelSanadPusherClient].
  static SanadPusherClientPlatform get instance => _instance;

  Map<String, PusherChannel> channels = {};
  String connected = 'CONNECTED';
  String disConnected = 'DISCONNECTED';
  String connectionState = 'DISCONNECTED';

  Function(String currentState, String previousState)? onConnectionStateChange;
  Function(String channelName, dynamic data)? onSubscriptionSucceeded;
  Function(String message, dynamic error)? onSubscriptionError;
  Function(String event, String reason)? onDecryptionFailure;
  Function(String message, int? code, dynamic error)? onError;
  Function(PusherEvent event)? onEvent;
  Function(String channelName, PusherMember member)? onMemberAdded;
  Function(String channelName, PusherMember member)? onMemberRemoved;
  Function(String channelName, int subscriptionCount)? onSubscriptionCount;

  Function(String channelName, String socketId, dynamic options)? onAuthorizer;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SanadPusherClientPlatform] when
  /// they register themselves.
  static set instance(SanadPusherClientPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> unsubscribe({required String channelName}) {
    throw UnimplementedError('not been implemented.');
  }

  Future<void> trigger(PusherEvent event) {
    throw UnimplementedError('not been implemented.');
  }

  Future<void> init({
    required String apiKey,
    required String cluster,
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
    throw UnimplementedError('not been implemented.');
  }

  Future<void> connect() async {
    throw UnimplementedError('not been implemented.');
  }

  Future<void> disconnect() async {
    throw UnimplementedError('not been implemented.');
  }

  Future<PusherChannel> subscribe(
      {required String channelName,
      var onSubscriptionSucceeded,
      var onSubscriptionError,
      var onMemberAdded,
      var onMemberRemoved,
      var onEvent,
      var onSubscriptionCount}) async {
    throw UnimplementedError('not been implemented.');
  }

  Future<String> getSocketId() async {
    throw UnimplementedError('not been implemented.');
  }

  PusherChannel? getChannel(String channelName) {
    throw UnimplementedError('not been implemented.');
  }
}

class PusherChannel {
  // PusherChannel.presence({
  //   required this.channelName,
  //   this.onSubscriptionSucceeded,
  //   this.onEvent,
  //   this.onMemberAdded,
  //   this.onMemberRemoved,
  //   this.onSubscriptionCount,
  //   this.me,
  // }) {
  //   channelName = 'presence-$channelName';
  // }

  String channelName;
  Map<String, PusherMember> members = {};
  PusherMember? me;
  int subscriptionCount = 0;

  Function(dynamic data)? onSubscriptionSucceeded;
  Function(dynamic event)? onEvent;
  Function(PusherMember member)? onMemberAdded;
  Function(PusherMember member)? onMemberRemoved;
  Function(int subscriptionCount)? onSubscriptionCount;
  PusherChannel({
    required this.channelName,
    this.onSubscriptionSucceeded,
    this.onEvent,
    this.onMemberAdded,
    this.onMemberRemoved,
    this.onSubscriptionCount,
    this.me,
  });
  Future<void> unsubscribe() async {
    return SanadPusherClientPlatform.instance
        .unsubscribe(channelName: channelName);
  }

  Future<void> trigger(PusherEvent event) async {
    if (event.channelName != channelName) {
      throw ('Event is not for this channel');
    }
    return SanadPusherClientPlatform.instance.trigger(event);
  }

  @override
  String toString() {
    return 'ChannelName $channelName, Me $me';
  }
}
