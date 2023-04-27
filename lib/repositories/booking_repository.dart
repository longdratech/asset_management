import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking/booking.dart';
import 'firestore_repository.dart';

class BookingRepository {
  final _firestore = FirestoreRepository();
  final path = 'booking';
  static final BookingRepository _singleton = BookingRepository._internal();

  factory BookingRepository() {
    return _singleton;
  }

  BookingRepository._internal();

  //
  Query<Map<String, dynamic>> collection() {
    return _firestore.collection(path);
  }

  Query<Map<String, dynamic>> collectionByTime(DateTime datetime) {
    final start =
        DateTime(datetime.year, datetime.month, datetime.day, 0, 0, 0);
    final end =
        DateTime(datetime.year, datetime.month, datetime.day, 23, 59, 59);
    return collection()
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end);
  }

  Stream<List<DocumentSnapshot>> selectAll({
    required DateTime datetime,
  }) {
    return collectionByTime(datetime).snapshots().map((snapshot) {
      return snapshot.docs;
    });
  }

  Future<DocumentReference> requestAsset(Booking data) async {
    return await _firestore.addDocument(path, data);
  }

  Future getDocumentBy({
    required DateTime datetime,
    required String assetCode,
  }) async {
    return collectionByTime(datetime)
        .where("assetCode", isEqualTo: assetCode)
        .limit(1)
        .get();
  }
}
