import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_repository.dart';

class BookingRepository {
  final _firestore = FirestoreRepository();
  static final BookingRepository _singleton = BookingRepository._internal();

  factory BookingRepository() {
    return _singleton;
  }

  BookingRepository._internal();

  Stream<List<DocumentSnapshot>> selectAll({
    required DateTime datetime,
  }) {
    return _firestore
        .collection('booking')
        .where('createdAt',
            isGreaterThan:
                Timestamp.fromDate(datetime.subtract(Duration(days: 1))))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs;
    });
  }
}
