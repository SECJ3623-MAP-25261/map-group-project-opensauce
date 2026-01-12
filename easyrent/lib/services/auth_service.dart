import 'package:cloud_firestore/cloud_firestore.dart'; // <--- Needed for the fix
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Login (Unchanged)
  Future<UserCredential> loginWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign Up (Fixed to save Phone Number)
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    // 1. Create User (Fires your Node 24 "beforeUserCreated" function)
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (cred.user != null) {
      // 2. Update Auth Display Name
      await cred.user!.updateDisplayName(name);
      await cred.user!.reload();

      // 3. MANUAL MERGE: Save Phone Number
      // Your Node.js function creates the document, but it doesn't know the phone number.
      // We use 'merge: true' to add the phone number without deleting what Node.js did.
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .set({
              'phoneNumber': phone,
              'displayName': name, // Save name here too just in case
            }, SetOptions(merge: true));
      } catch (e) {
        print("Error saving phone to DB: $e");
      }
    }

    return cred;
  }

  // Google Sign In
  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. FORCE ACCOUNT PICKER: Sign out of Google locally first
      // This forces the "Choose an account" dialog to appear every time.
      await _googleSignIn.signOut();

      // 2. Now start the sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null; // User canceled the picker

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Sign in to Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Google Sign In Error: $e");
      return null;
    }
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
