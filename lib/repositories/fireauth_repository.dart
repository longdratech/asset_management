import 'package:firebase_auth/firebase_auth.dart';

class FireAuthRepository {
  static final FireAuthRepository _singleton = FireAuthRepository._internal();

  factory FireAuthRepository() {
    return _singleton;
  }

  FireAuthRepository._internal();

  Stream<User?> currentUser() {
    return FirebaseAuth.instance.userChanges();
  }

  User? getUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
