// ignore_for_file: avoid_print

/// Firebase initialization wrapper for KienCare Mobile Store.
///
/// All Firebase calls are wrapped in try/catch so the app runs gracefully
/// in "mock mode" when Firebase is not configured. Set up your Firebase project:
///
/// 1. Go to https://console.firebase.google.com
/// 2. Create a new project called "KienCare Mobile"
/// 3. Add an Android app with package ID: com.kiencare.mobile
/// 4. Download google-services.json → place in android/app/
/// 5. Enable: Authentication, Firestore, Storage, Cloud Messaging
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  /// Whether Firebase was successfully initialized.
  static bool get isInitialized => _initialized;

  /// Initialize Firebase. Returns true on success, false if not configured.
  static Future<bool> initialize() async {
    // TODO: Firebase — Uncomment after adding google-services.json
    // try {
    //   await Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform,
    //   );
    //   _initialized = true;
    //   print('[FirebaseService] Firebase initialized successfully.');
    //   return true;
    // } catch (e) {
    //   print('[FirebaseService] Firebase init failed: $e');
    //   print('[FirebaseService] Running in mock mode.');
    //   _initialized = false;
    //   return false;
    // }

    // Mock mode (no Firebase configured):
    print('[FirebaseService] Running in MOCK mode — Firebase not configured.');
    _initialized = false;
    return false;
  }
}
