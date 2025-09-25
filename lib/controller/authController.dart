import 'package:bbs_booking_system/controller/dbController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<User?> signInWithEmailAndPassword(
      String email, String password, bool autologin) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (autologin) {
        await DatabaseHelper().insertUser(email, userCredential.user!.uid);
      }
      return userCredential.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  Future<User?> signUpUser(
      String email, String password, String displayName, bool autologin) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'displayName': displayName,
          'email': email,
          'joinedIn': Timestamp.now(),
          'member': false
        });
        if (autologin) {
          await DatabaseHelper().insertUser(email, userCredential.user!.uid);
        }
      } catch (e) {
        print("Error registering user: $e");
        return null;
      }

      await userCredential.user!.updateDisplayName(displayName);
      return userCredential.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    return await DatabaseHelper().isUsernamePresent(username);
  }
}
