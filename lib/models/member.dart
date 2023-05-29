import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'json_map.dart';

class Member {
  final String? id;
  final String name;
  final String email;

  Member({required this.name, this.id, required this.email});

  factory Member.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as JsonMap;
    return Member(id: snapshot.id, name: data['name'], email: data['email']);
  }

  JsonMap toFirestore() {
    return {
      "id": id ?? const Uuid().v4(),
      "name": name,
      "email": email,
    };
  }
}
