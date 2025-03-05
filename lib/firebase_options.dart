// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDtsRycMxjr2eamSiH17ER9GGqA3g3bAoU',
    appId: '1:47813182020:web:f3170e7064c874e1c5b211',
    messagingSenderId: '47813182020',
    projectId: 'flutterapp-2e09f',
    authDomain: 'flutterapp-2e09f.firebaseapp.com',
    storageBucket: 'flutterapp-2e09f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJxHiNvyBASTUNNFlY3HKR5ZcAogiFH8w',
    appId: '1:47813182020:android:7dbdef591e4a8c33c5b211',
    messagingSenderId: '47813182020',
    projectId: 'flutterapp-2e09f',
    storageBucket: 'flutterapp-2e09f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB7Vv2h3NkAhy2oonsTSucPp1g4kn4hFJs',
    appId: '1:47813182020:ios:990402d68c99cff0c5b211',
    messagingSenderId: '47813182020',
    projectId: 'flutterapp-2e09f',
    storageBucket: 'flutterapp-2e09f.firebasestorage.app',
    iosBundleId: 'com.example.firebase',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB7Vv2h3NkAhy2oonsTSucPp1g4kn4hFJs',
    appId: '1:47813182020:ios:990402d68c99cff0c5b211',
    messagingSenderId: '47813182020',
    projectId: 'flutterapp-2e09f',
    storageBucket: 'flutterapp-2e09f.firebasestorage.app',
    iosBundleId: 'com.example.firebase',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDtsRycMxjr2eamSiH17ER9GGqA3g3bAoU',
    appId: '1:47813182020:web:91127c076603c3e6c5b211',
    messagingSenderId: '47813182020',
    projectId: 'flutterapp-2e09f',
    authDomain: 'flutterapp-2e09f.firebaseapp.com',
    storageBucket: 'flutterapp-2e09f.firebasestorage.app',
  );
}
