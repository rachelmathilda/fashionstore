import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === Shared Preferences ===
  static Future<void> saveUserSession(
    String userId, {
    bool rememberMe = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setBool('rememberMe', rememberMe);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('rememberMe') ?? false;
  }

  // === Register with Email ===
  static Future<void> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Simpan ke Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'user_id': user.uid,
          'email': email,
          'name': name,
          'username': username,
          'created_at': FieldValue.serverTimestamp(),
        });

        await saveUserSession(user.uid, rememberMe: true);
      } else {
        throw Exception('Registrasi gagal');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Registrasi gagal: ${e.message}');
    } catch (e) {
      throw Exception('Registrasi gagal: $e');
    }
  }

  // === Login with Email ===
  static Future<void> signInWithEmail({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        await saveUserSession(user.uid, rememberMe: rememberMe);
      } else {
        throw Exception('Login gagal');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Login gagal: ${e.message}');
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }

  // === Login with Google ===
  static Future<void> signInWithGoogle({required bool rememberMe}) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign-In dibatalkan');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!doc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'user_id': user.uid,
            'email': user.email ?? '',
            'name': user.displayName ?? 'Google User',
            'username': user.email?.split('@')[0] ?? 'google_user',
            'created_at': FieldValue.serverTimestamp(),
          });
        }

        await saveUserSession(user.uid, rememberMe: rememberMe);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Google Sign-In gagal: ${e.message}');
    } catch (e) {
      throw Exception('Google Sign-In gagal: $e');
    }
  }

  // === Login with Apple ===
  static Future<void> signInWithApple({required bool rememberMe}) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: appleCredential.authorizationCode,
      );

      UserCredential result = await _auth.signInWithCredential(oauthCredential);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!doc.exists) {
          String name =
              appleCredential.givenName ??
              appleCredential.familyName ??
              'Apple User';
          String username = user.email?.split('@')[0] ?? 'apple_user';

          await _firestore.collection('users').doc(user.uid).set({
            'user_id': user.uid,
            'email': user.email ?? '',
            'name': name,
            'username': username,
            'created_at': FieldValue.serverTimestamp(),
          });
        }

        await saveUserSession(user.uid, rememberMe: rememberMe);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Apple Sign-In gagal: ${e.message}');
    } on SignInWithAppleException catch (e) {
      throw Exception('Apple Sign-In gagal: $e');
    } catch (e) {
      throw Exception('Apple Sign-In gagal: $e');
    }
  }

  // === Sign Out ===
  static Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('rememberMe');
  }

  // === Get Current User (Opsional) ===
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}
