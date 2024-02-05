import 'dart:convert';

import 'package:http/http.dart' as http;

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

  @override
  String toString() =>
      '{ channelName: $channelName, eventName: $eventName, data: $data, userId: $userId }';

  bool isNotRegular() {
    return ! eventName.contains('subscription_succeeded');
  }
}

class PusherMember {
  String userId;
  dynamic userInfo;

  PusherMember(this.userId, this.userInfo);

  @override
  String toString() => '{ userId: $userId, userInfo: $userInfo }';
}

// getSignature(String signature) {
//   var key = utf8.encode('sec');
//   var bytes = utf8.encode(signature);
//   var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
//   var digest = hmacSha256.convert(bytes);
//   // print("HMAC signature in string is: $digest");
//   return digest;
// }

dynamic Authorizer(String channelName, String socketId, dynamic options) async {
  String token = "2|yxfhvJjork9HnnxL6y0jF4JXyIJxbJdRoge3clq1381f054e";
  var authUrl = "http://192.168.0.235:8000/api/broadcasting/auth";
  var result = await http.post(
    Uri.parse(authUrl),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token}',
    },
    body: 'socket_id=$socketId&channel_name=$channelName',
  );
  var json = jsonDecode(result.body);
  return json;
}
