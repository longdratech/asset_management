import 'package:assets_management/models/json_map.dart';

class FirestoreDocument {
  final String id;
  final JsonMap data;

  FirestoreDocument(this.id, this.data);
}