import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocksCallback(() async {
    // Correct channel name for firebase_core
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
  });
}

typedef Callback = Future<void> Function();

void setupFirebaseCoreMocksCallback(Callback callback) {
  callback();
}
