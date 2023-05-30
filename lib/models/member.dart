import 'package:assets_management/enums/role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'json_map.dart';

class Member {
  final String? id;
  final String name;
  final String email;
  final Role? role;

  Member({required this.name, this.id, required this.email, this.role});

  factory Member.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as JsonMap;

    Role convertStringToEnum(String role) {
      for (var enumValue in Role.values) {
        if (enumValue.toString() == 'Role.$role') {
          return enumValue;
        }
      }
      return Role.user;
    }

    return Member(
      id: snapshot.id,
      name: data['name'],
      email: data['email'],
      role: data['role'] != null ? convertStringToEnum(data['role']) : null,
    );
  }

  JsonMap toFirestore() {
    return {
      "id": id ?? const Uuid().v4(),
      "name": name,
      "email": email,
      'role': role,
    };
  }
}
