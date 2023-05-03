import 'package:assets_management/models/json_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String assetRef;
  final DateTime createdAt;
  final String employee;
  final DateTime? endedAt;

  Booking({
    required this.id,
    required this.assetRef,
    required this.createdAt,
    required this.employee,
    this.endedAt,
  });

  factory Booking.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as JsonMap;
    return Booking(
      id: snapshot.id,
      assetRef: data['asset'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      employee: data['employee'],
      endedAt: data['endedAt'] != null
          ? (data['endedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'createdAt': createdAt,
      'employee': employee,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
    };
  }
}
