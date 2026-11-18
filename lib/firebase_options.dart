import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Android configuration from the existing android/app/google-services.json.
/// Run flutterfire configure to register and configure additional platforms.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'Firebase não configurado nesta plataforma. Execute flutterfire configure.',
    );
  }

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyBD82eIFoGCcMMpKuxOat6XI-PG7Mrsb4o',
    appId: '1:1030671739097:android:2df9793c37e0d6147cb6c8',
    messagingSenderId: '1030671739097',
    projectId: 'ecomfirebaseapp-73b2a',
    storageBucket: 'ecomfirebaseapp-73b2a.firebasestorage.app',
  );
}
