import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<void> saveUserSession(
    String userId, {
    bool rememberMe = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('userId', userId);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('userId');
      await prefs.setBool('rememberMe', false);
    }
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    if (!rememberMe) return null;
    return prefs.getString('userId');
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('rememberMe') ?? false;
  }

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
        await user.sendEmailVerification();

        await _firestore.collection('users').doc(user.uid).set({
          'user_id': user.uid,
          'email': email,
          'name': name,
          'username': username,
          'created_at': FieldValue.serverTimestamp(),
        });

        await saveUserSession(user.uid, rememberMe: true);
      } else {
        throw Exception('Registration failed');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

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
        if (!user.emailVerified) {
          await _auth.signOut();
          throw Exception('Please verify your email before signing in.');
        }
        await saveUserSession(user.uid, rememberMe: rememberMe);
      } else {
        throw Exception('Login failed');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signInWithGoogle({required bool rememberMe}) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) throw Exception('Google Sign-In cancelled');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
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
      throw Exception(_mapAuthError(e.code));
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signInWithApple({required bool rememberMe}) async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      UserCredential result = await _auth.signInWithCredential(oauthCredential);
      User? user = result.user;

      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          final name = [
            appleCredential.givenName,
            appleCredential.familyName,
          ].where((e) => e != null && e.isNotEmpty).join(' ');

          await _firestore.collection('users').doc(user.uid).set({
            'user_id': user.uid,
            'email': user.email ?? '',
            'name': name.isNotEmpty ? name : 'Apple User',
            'username': user.email?.split('@')[0] ?? 'apple_user',
            'created_at': FieldValue.serverTimestamp(),
          });
        }
        await saveUserSession(user.uid, rememberMe: rememberMe);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } on SignInWithAppleAuthorizationException catch (e) {
      throw Exception('Apple Sign-In failed: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('rememberMe');
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  static String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication error: $code';
    }
  }
}
