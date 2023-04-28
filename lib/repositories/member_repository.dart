import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/member.dart';
import 'firestore_repository.dart';

class MemberRepository {
  final _firestore = FirestoreRepository();
  final path = 'members';

  static final MemberRepository _singleton = MemberRepository._internal();

  factory MemberRepository() {
    return _singleton;
  }

  MemberRepository._internal();

  //
  Query<Map<String, dynamic>> collection() {
    return _firestore.collection(path);
  }

  Stream<List<Member>> selectAll() {
    return collection().snapshots().map((snapshot) {
      return snapshot.docs;
    }).map(
      (data) {
        return data.map((doc) {
          return Member.fromFirestore(doc);
        }).toList();
      },
    );
  }
}
