// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAv17akx9kKvZlyT7gSU_16yHh5afX1Yug',
    appId: '1:216294869323:web:3415bfa17c029e1dbb80ce',
    messagingSenderId: '216294869323',
    projectId: 'mask-detect-66aaf',
    authDomain: 'mask-detect-66aaf.firebaseapp.com',
    storageBucket: 'mask-detect-66aaf.appspot.com',
    measurementId: 'G-ZWMNJS5JBS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0MPWGZ8m-bAjL9Ud7EwwaQVUYrWBjfMw',
    appId: '1:216294869323:android:1f147796c5b0f506bb80ce',
    messagingSenderId: '216294869323',
    projectId: 'mask-detect-66aaf',
    storageBucket: 'mask-detect-66aaf.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCGHo5mnmZQoR7rel-gnRgFDqBS9osUjbU',
    appId: '1:216294869323:ios:87a2338e3a82b22ebb80ce',
    messagingSenderId: '216294869323',
    projectId: 'mask-detect-66aaf',
    storageBucket: 'mask-detect-66aaf.appspot.com',
    iosClientId: '216294869323-6jlsdl3dck22t5vqerfajl65ler53i5n.apps.googleusercontent.com',
    iosBundleId: 'com.example.maskDetect',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCGHo5mnmZQoR7rel-gnRgFDqBS9osUjbU',
    appId: '1:216294869323:ios:87a2338e3a82b22ebb80ce',
    messagingSenderId: '216294869323',
    projectId: 'mask-detect-66aaf',
    storageBucket: 'mask-detect-66aaf.appspot.com',
    iosClientId: '216294869323-6jlsdl3dck22t5vqerfajl65ler53i5n.apps.googleusercontent.com',
    iosBundleId: 'com.example.maskDetect',
  );
}
