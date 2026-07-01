import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  /// Called once on app start. Silent — no UI.
  static Future<void> signInAnonymously() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
    } catch (_) {
      // Ignore auth errors in demo/offline mode
    }
  }

  static String? get currentUid => _auth.currentUser?.uid;
}
