import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  //create instance of FirebaseAuth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //geting for current authenticated user
  User? get currentUser => _firebaseAuth.currentUser;
  //provides updates on the user's authentication state
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  //method to sign in a user using their email and password
  Future<void> signInWithEmailAndPassword({
    required String email, //email for authentication
    required String password, //password for authentication
  }) async {
    //perform sign in operation with the provided email and password
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
