import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../json_map.dart';

@JsonSerializable()
class Asset {
  const Asset({
    required this.id,
    required this.assetCode,
    this.modelName,
    this.serialNumber,
    required this.type,
  });

  final String id;
  final String assetCode;
  final String? modelName;
  final String? serialNumber;
  final String type;

  factory Asset.fromFirestore(JsonMap data) {
    return Asset(
      id: data['id'],
      assetCode: data['assetCode'],
      modelName: data['modelName'],
      serialNumber: data['serialNumber'],
      type: data['type'],
    );
  }

  JsonMap toFirestore() {
    return {
      "id": id,
      "assetCode": assetCode,
      "modelName": modelName,
      if (serialNumber != null) "serialNumber": serialNumber,
      "type": type,
    };
  }
}
