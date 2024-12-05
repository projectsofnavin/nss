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
    apiKey: 'AIzaSyC6NvDqlyrraL2eQoH5rsE1ZHiZftWBUfk',
    appId: '1:779151419426:web:361b5845201ee49b36c27b',
    messagingSenderId: '779151419426',
    projectId: 'nawaurjaseel',
    authDomain: 'nawaurjaseel.firebaseapp.com',
    storageBucket: 'nawaurjaseel.firebasestorage.app',
    measurementId: 'G-Z5HJJ4JL3X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDbUatg-PSHuwQ_8EtIFkW7Kn_ZdZKLw30',
    appId: '1:779151419426:android:d1ef8e4b6e81a62136c27b',
    messagingSenderId: '779151419426',
    projectId: 'nawaurjaseel',
    storageBucket: 'nawaurjaseel.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMG4Veeipps_xy51dx0XIuBINPwYCY-IA',
    appId: '1:779151419426:ios:1e7e5ab5a9773e0836c27b',
    messagingSenderId: '779151419426',
    projectId: 'nawaurjaseel',
    storageBucket: 'nawaurjaseel.firebasestorage.app',
    iosBundleId: 'com.example.nss',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCMG4Veeipps_xy51dx0XIuBINPwYCY-IA',
    appId: '1:779151419426:ios:1e7e5ab5a9773e0836c27b',
    messagingSenderId: '779151419426',
    projectId: 'nawaurjaseel',
    storageBucket: 'nawaurjaseel.firebasestorage.app',
    iosBundleId: 'com.example.nss',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC6NvDqlyrraL2eQoH5rsE1ZHiZftWBUfk',
    appId: '1:779151419426:web:a2f14fe061e3fb5a36c27b',
    messagingSenderId: '779151419426',
    projectId: 'nawaurjaseel',
    authDomain: 'nawaurjaseel.firebaseapp.com',
    storageBucket: 'nawaurjaseel.firebasestorage.app',
    measurementId: 'G-YSRTGZ574Q',
  );
}