import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Pigeon channel (Used by newer firebase_core versions)
  const channelName = 'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeCore';

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
    BasicMessageChannel(channelName, StandardMessageCodec()),
    (message) async {
      return [
        {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': {},
        }
      ];
    },
  );

  // Mock Legacy MethodChannel (Used by older firebase_core versions or specific methods)
  const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_core');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (call) async {
      if (call.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': '123',
              'appId': '123',
              'messagingSenderId': '123',
              'projectId': '123',
            },
            'pluginConstants': {},
          }
        ];
      }
      if (call.method == 'Firebase#initializeApp') {
        return {
          'name': call.arguments['appName'],
          'options': call.arguments['options'],
          'pluginConstants': {},
        };
      }
      return null;
    },
  );
}

typedef Callback = Future<void> Function();

void setupFirebaseCoreMocksCallback(Callback callback) {
  callback();
}
