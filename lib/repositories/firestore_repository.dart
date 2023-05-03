import 'package:assets_management/models/json_map.dart';
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

  Future<DocumentReference> addDocument(
    String collectionPath,
    dynamic data,
  ) async {
    return await FirebaseFirestore.instance
        .collection(collectionPath)
        .add(data);
  }

  DocumentReference<JsonMap> doc(String ref) {
    return FirebaseFirestore.instance.doc(ref);
  }
}
