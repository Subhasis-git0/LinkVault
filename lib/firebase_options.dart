
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
    apiKey: 'AIzaSyAvUx3UWjY7Lmg4pkUIGVjnHl1pVm5FwT4',
    appId: '1:471937160258:web:a697a2b6995d5a8a0909db',
    messagingSenderId: '471937160258',
    projectId: 'linkvault-9cd9c',
    authDomain: 'linkvault-9cd9c.firebaseapp.com',
    storageBucket: 'linkvault-9cd9c.firebasestorage.app',
    measurementId: 'G-VPDMWH3NXN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_KF_yAuqDxtopW5sXAPBOuAaPuw5V_io',
    appId: '1:471937160258:android:f5a702a56453504b0909db',
    messagingSenderId: '471937160258',
    projectId: 'linkvault-9cd9c',
    storageBucket: 'linkvault-9cd9c.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBx46mIKmfmFPfkv1rWUtjBxLGxAWGlmpw',
    appId: '1:471937160258:ios:99a495526f484eec0909db',
    messagingSenderId: '471937160258',
    projectId: 'linkvault-9cd9c',
    storageBucket: 'linkvault-9cd9c.firebasestorage.app',
    iosBundleId: 'com.example.linkvault',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBx46mIKmfmFPfkv1rWUtjBxLGxAWGlmpw',
    appId: '1:471937160258:ios:99a495526f484eec0909db',
    messagingSenderId: '471937160258',
    projectId: 'linkvault-9cd9c',
    storageBucket: 'linkvault-9cd9c.firebasestorage.app',
    iosBundleId: 'com.example.linkvault',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAvUx3UWjY7Lmg4pkUIGVjnHl1pVm5FwT4',
    appId: '1:471937160258:web:35e5c1180593c2990909db',
    messagingSenderId: '471937160258',
    projectId: 'linkvault-9cd9c',
    authDomain: 'linkvault-9cd9c.firebaseapp.com',
    storageBucket: 'linkvault-9cd9c.firebasestorage.app',
    measurementId: 'G-E9PD04GQ5G',
  );
}
