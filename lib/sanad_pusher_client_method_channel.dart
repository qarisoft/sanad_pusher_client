import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sanad_pusher_client/utils.dart';

import 'sanad_pusher_client_platform_interface.dart';

/// An implementation of [SanadPusherClientPlatform] that uses method channels.
class MethodChannelSanadPusherClient extends SanadPusherClientPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('sanad_pusher_client');

  @override
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
    methodChannel.setMethodCallHandler(_platformCallHandler);
    this.onConnectionStateChange = onConnectionStateChange;
    this.onError = onError;
    this.onSubscriptionSucceeded = onSubscriptionSucceeded;
    this.onEvent = onEvent;
    this.onSubscriptionError = onSubscriptionError;
    this.onDecryptionFailure = onDecryptionFailure;
    this.onMemberAdded = onMemberAdded;
    this.onMemberRemoved = onMemberRemoved;
    this.onAuthorizer = onAuthorizer;
    this.onSubscriptionCount = onSubscriptionCount;
    await methodChannel.invokeMethod('init', {
      "apiKey": apiKey,
      "cluster": cluster,
      "useTLS": useTLS,
      "proxy": proxy,
      "setHost": setHost,
      "setWsPort": setWsPort,
      "setWssPort": setWssPort,
      "activityTimeout": activityTimeout,
      "pongTimeout": pongTimeout,
      "maxReconnectionAttempts": maxReconnectionAttempts,
      "maxReconnectGapInSeconds": maxReconnectGapInSeconds,
      "authorizer": onAuthorizer != null ? true : null,
    });
  }

  Future<dynamic> _platformCallHandler(MethodCall call) async {
    final String? channelName = call.arguments['channelName'];
    final String? eventName = call.arguments['eventName'];
    final dynamic data = call.arguments['data'];
    final dynamic user = call.arguments['user'];
    final String? userId = call.arguments["userId"];

    switch (call.method) {
      case 'onConnectionStateChange':
        connectionState = call.arguments['currentState'].toUpperCase();
        onConnectionStateChange?.call(
            call.arguments['currentState'].toUpperCase(),
            call.arguments['previousState'].toUpperCase());
        return Future.value(null);

      case 'onError':
        onError?.call(call.arguments['message'], call.arguments['code'],
            call.arguments['error']);
        return Future.value(null);

      case 'onEvent':
        switch (eventName) {
          case 'pusher:subscription_succeeded':
          case 'pusher_internal:subscription_succeeded':
            // Depending on the platform implementation we get json or a Map.
            var decodedData = data is Map ? data : jsonDecode(data);
            decodedData?["presence"]?["hash"]?.forEach((userId_, userInfo) {
              var member = PusherMember(userId_, userInfo);
              channels[channelName]?.members[userId_] = member;
              if (userId_ == userId) {
                channels[channelName]?.me = member;
              }
            });

            onSubscriptionSucceeded?.call(channelName!, decodedData);
            channels[channelName]?.onSubscriptionSucceeded?.call(decodedData);
            break;
          case 'pusher:subscription_count':
          case 'pusher_internal:subscription_count':
            // Depending on the platform implementation we get json or a Map.
            var decodedData = data is Map ? data : jsonDecode(data);
            var subscriptionCount = decodedData['subscription_count'];
            channels[channelName]?.subscriptionCount = subscriptionCount;
            onSubscriptionCount?.call(channelName!, subscriptionCount);
            channels[channelName]?.onSubscriptionCount?.call(subscriptionCount);
            break;
        }

        final event = PusherEvent(
            channelName: channelName!,
            eventName: eventName!.replaceFirst("pusher_internal", "pusher"),
            data: data,
            userId: call.arguments['userId']);
        onEvent?.call(event);
        channels[channelName]?.onEvent?.call(event);
        return Future.value(null);

      case 'onSubscriptionError':
        onSubscriptionError?.call(
            call.arguments['message'], call.arguments['error']);
        return Future.value(null);

      case 'onDecryptionFailure':
        onDecryptionFailure?.call(
            call.arguments['event'], call.arguments['reason']);
        return Future.value(null);

      case 'onMemberAdded':
        var member = PusherMember(user["userId"], user["userInfo"]);
        channels[channelName]?.members[member.userId] = member;
        onMemberAdded?.call(channelName!, member);
        channels[channelName]?.onMemberAdded?.call(member);
        return Future.value(null);

      case 'onMemberRemoved':
        var member = PusherMember(user["userId"], user["userInfo"]);
        channels[channelName]?.members.remove(member.userId);
        onMemberRemoved?.call(channelName!, member);
        channels[channelName]?.onMemberRemoved?.call(member);
        return Future.value(null);

      case 'onAuthorizer':
        log('call.arguments[options] ${call.arguments['options'].toString()}');
        return await onAuthorizer?.call(channelName!,
            call.arguments['socketId'], call.arguments['options']);
      default:
        throw MissingPluginException('Unknown method ${call.method}');
    }
  }

  @override
  Future<void> connect() async {
    await methodChannel.invokeMethod('connect');
  }

  @override
  Future<void> disconnect() async {
    await methodChannel.invokeMethod('disconnect');
  }

  @override
  Future<PusherChannel> subscribe(
      {required String channelName,
      var onSubscriptionSucceeded,
      var onSubscriptionError,
      var onMemberAdded,
      var onMemberRemoved,
      var onEvent,
      var onSubscriptionCount}) async {
    var channel = PusherChannel(
        channelName: channelName,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        onSubscriptionCount: onSubscriptionCount,
        onEvent: onEvent);
    await methodChannel.invokeMethod("subscribe", {"channelName": channelName});
    channels[channelName] = channel;
    return channel;
  }

  @override
  Future<void> unsubscribe({required String channelName}) async {
    channels.remove(channelName);
    await methodChannel
        .invokeMethod("unsubscribe", {"channelName": channelName});
  }

  @override
  Future<void> trigger(PusherEvent event) async {
    // if ()
    log('connectionState from triger $connectionState');
    if (event.channelName.startsWith("private-") ||
        event.channelName.startsWith("presence-")) {
      var data = jsonEncode(event.data);
      try {
        await methodChannel.invokeMethod('trigger', {
          "channelName": event.channelName,
          "eventName": event.eventName,
          "data": data
        });
      } catch (e) {
        log('error from trigger $e');
      }
    } else {
      throw ('Trigger event is only for private/presence channels');
    }
  }

  @override
  Future<String> getSocketId() async {
    return (await methodChannel.invokeMethod('getSocketId')).toString();
  }

  @override
  PusherChannel? getChannel(String channelName) {
    return channels[channelName];
  }
}
