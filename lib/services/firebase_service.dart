import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Initializes Firebase using the native platform configuration.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;
  static Object? _initializationError;

  static bool get isInitialized => _initialized;
  static Object? get initializationError => _initializationError;

  static Future<bool> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _initialized = true;
      _initializationError = null;
      return true;
    } catch (error) {
      _initialized = false;
      _initializationError = error;
      return false;
    }
  }
}