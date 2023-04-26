import 'package:assets_management/models/booking/booking.dart';

import 'firestore_repository.dart';

class BookingRepository {
  final FirestoreRepository _firestore;

  const BookingRepository({required FirestoreRepository firestore})
      : _firestore = firestore;

  Stream<List<Booking>> selectAll() {
    return _firestore.selectDocs('booking').map(
      (data) {
        return data.map((doc) => Booking.fromDocumentSnapshot(doc)).toList();
      },
    );
  }
}
