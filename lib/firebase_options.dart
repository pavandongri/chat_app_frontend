import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase project config for `chatapp-affba`, sourced from
/// `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.
/// Local (in-app/WebSocket-driven) notifications work regardless — only the
/// FCM push path depends on this file.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web — this '
        'app only targets Android and iOS.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for Android and iOS, '
          'got $defaultTargetPlatform.',
        );
    }
  }

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyATYzkSB2q6PMUxgS_vCiOuPmSHbGSUqxA',
    appId: '1:468081044227:android:9100a71d028acad73e1736',
    messagingSenderId: '468081044227',
    projectId: 'chatapp-affba',
    storageBucket: 'chatapp-affba.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: 'AIzaSyDJTkKfHrgEfo9iOIOYQfXh9wftF0qOgEM',
    appId: '1:468081044227:ios:af93b39fe39027a93e1736',
    messagingSenderId: '468081044227',
    projectId: 'chatapp-affba',
    storageBucket: 'chatapp-affba.firebasestorage.app',
    iosBundleId: 'com.example.chatApp',
  );
}
