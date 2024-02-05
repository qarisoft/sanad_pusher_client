// class MockSanadPusherClientPlatform
//     with MockPlatformInterfaceMixin
//     implements SanadPusherClientPlatform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final SanadPusherClientPlatform initialPlatform = SanadPusherClientPlatform.instance;
//
//   test('$MethodChannelSanadPusherClient is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelSanadPusherClient>());
//   });
//
//   test('getPlatformVersion', () async {
//     SanadPusherClient sanadPusherClientPlugin = SanadPusherClient();
//     MockSanadPusherClientPlatform fakePlatform = MockSanadPusherClientPlatform();
//     SanadPusherClientPlatform.instance = fakePlatform;
//
//     expect(await sanadPusherClientPlugin.getPlatformVersion(), '42');
//   });
// }
