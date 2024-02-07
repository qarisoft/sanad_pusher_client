import 'dart:convert';

import 'package:crypto/crypto.dart';

// import 'package:cr';
class PusherEvent {
  String channelName;
  String eventName;
  dynamic data;
  String? userId;
  PusherEvent({
    required this.channelName,
    required this.eventName,
    this.data,
    this.userId,
  });

  PusherEvent copyWith({
    data,
  }) {
    this.data = data;
    return this;
  }

  @override
  String toString() =>
      '{ channelName: $channelName, eventName: $eventName, data: $data, userId: $userId }';

  bool isNotRegular() {
    return !eventName.contains('subscription_succeeded');
  }
}

class PusherMember {
  String userId;
  dynamic userInfo;

  PusherMember(this.userId, this.userInfo);

  @override
  String toString() => '{ userId: $userId, userInfo: $userInfo }';
}

getSignature(String signature, [String sec = 'sec']) {
  var key = utf8.encode(sec);
  var bytes = utf8.encode(signature);
  var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
  var digest = hmacSha256.convert(bytes);
  return digest;
}
