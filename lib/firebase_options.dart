// Generated manually from google-services.json
// Project: cakhiaquiz | Package: com.cakhia.gonquiz
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform is not configured. Run FlutterFire CLI to add web support.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS platform is not configured. Run FlutterFire CLI to add iOS support.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCt2KPknWGScJk6P3dy_bGjtdtLfI6jmQo',
    appId: '1:408976118138:android:5427b8ec1cbccddcca86c3',
    messagingSenderId: '408976118138',
    projectId: 'cakhiaquiz',
    storageBucket: 'cakhiaquiz.firebasestorage.app',
  );
}
