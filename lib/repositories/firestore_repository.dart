import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepository {
  static final FirestoreRepository _singleton = FirestoreRepository._internal();

  factory FirestoreRepository() {
    return _singleton;
  }

  FirestoreRepository._internal();

  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return FirebaseFirestore.instance.collection(collectionPath);
  }
}

