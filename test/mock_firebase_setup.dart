// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';

void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Use the official helper from the platform interface which handles Pigeon
  setupFirebaseCoreMocksCallback(() async {
    // This helper sets up the TestFirebaseCoreHostApi mock
    MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
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
    });
  });
}

typedef Callback = Future<void> Function();

void setupFirebaseCoreMocksCallback(Callback callback) {
  // This logic mimics what the official `setupFirebaseCoreMocks` does if we could import it directly from the test helper.
  // Since we can't easily reach the test helper file in the package, we rely on the implementation details.
  // HOWEVER, the error was about Pigeon channel `dev.flutter.pigeon...`.
  // The `firebase_core_platform_interface` package exports `setupFirebaseCoreMocks` usually?
  // Let's try to find if we can just mock the Pigeon channel manually if the import fails.

  // Actually, standard practice now is:
  // import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
  // ... setupFirebaseCoreMocks();
  // But `setupFirebaseCoreMocks` is often not exported in the main library, but in `src`.

  // Let's blindly try to mock the Pigeon channel.
  const channelName = 'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeCore';

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler(
    BasicMessageChannel(channelName, StandardMessageCodec()),
    (message) async {
        // Return dummy data matching `PigeonInitializeResponse`
        return {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': '123',
              'appId': '123',
              'messagingSenderId': '123',
              'projectId': '123',
            },
            'pluginConstants': {},
        };
    }
  );

  // Also mock the old channel just in case
  const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_core');
  channel.setMockMethodCallHandler((call) async {
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
  });

  callback();
}
