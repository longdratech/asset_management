import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import 'json_map.dart';
import 'package:uuid/uuid.dart';

class Asset {
  const Asset({
    this.id,
    required this.assetCode,
    this.pictures,
    this.modelName,
    this.serialNumber,
    required this.type,
  });

  final String? id;
  final String assetCode;
  final List<String>? pictures;
  final String? modelName;
  final String? serialNumber;
  final String type;

  factory Asset.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as JsonMap;
    return Asset(
      id: snapshot.id,
      assetCode: data['assetCode'],
      modelName: data['modelName'],
      pictures: data['pictures'] ?? [],
      serialNumber: data['serialNumber'],
      type: data['type'],
    );
  }

  JsonMap toFirestore() {
    return {
      "id": id ?? const Uuid().v4(),
      "assetCode": assetCode,
      "modelName": modelName,
      if (serialNumber != null) "serialNumber": serialNumber,
      "type": type,
    };
  }
}
