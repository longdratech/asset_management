import 'package:cloud_firestore/cloud_firestore.dart';

import '../blocs/booking/booking_event.dart';
import '../models/booking.dart';
import '../models/json_map.dart';
import 'firestore_repository.dart';

class BookingRepository {
  final _firestore = FirestoreRepository();
  final path = 'bookings';
  static final BookingRepository _singleton = BookingRepository._internal();

  factory BookingRepository() {
    return _singleton;
  }

  BookingRepository._internal();

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

  DocumentReference<JsonMap> reference(String ref) {
    return _firestore.doc(ref);
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

  Future<Booking> addOne(ReqBooking reqBooking) async {
    final a = await _firestore.collection(path).add({
      "asset": reqBooking.assetRef,
      "createdAt": reqBooking.createdAt ?? Timestamp.now(),
      "employee": reqBooking.name,
      "endedAt": null
    });

    return Booking.fromDocumentSnapshot(await a.get());
  }
}
