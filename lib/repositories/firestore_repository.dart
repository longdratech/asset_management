import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepository {
  // const FirestoreRepository();
  static final FirestoreRepository _singleton = FirestoreRepository._internal();

  factory FirestoreRepository() {
    return _singleton;
  }

  FirestoreRepository._internal();

  Stream<List<DocumentSnapshot>> selectDocs(String collectionPath) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs;
      },
    );
  }
}
