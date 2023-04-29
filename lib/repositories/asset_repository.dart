import 'package:assets_management/models/asset.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../blocs/asset/asset_event.dart';
import '../models/json_map.dart';
import 'firestore_repository.dart';

class AssetRepository {
  final _firestore = FirestoreRepository();
  final path = 'assets';
  static final AssetRepository _singleton = AssetRepository._internal();

  factory AssetRepository() {
    return _singleton;
  }

  AssetRepository._internal();

  Query<Map<String, dynamic>> collection() {
    return _firestore.collection(path);
  }

  Stream<List<Asset>> selectAll(LoadAsset event) {
    return collection()
        .where("assetCode", isEqualTo: event.assetCode)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs;
    }).map(
      (data) {
        return data.map((doc) {
          return Asset.fromFirestore(doc);
        }).toList();
      },
    );
  }

  Stream<Asset> selectOne(LoadAssetById event) {
    return _firestore
        .collection(path)
        .doc(event.documentId)
        .snapshots()
        .map((snapshot) {
      return Asset.fromFirestore(snapshot);
    });
  }

  Future<DocumentReference<Map<String, dynamic>>> addOne(Asset asset) async {
    return await _firestore.collection(path).add(asset.toFirestore());
  }

  Future<DocumentReference<JsonMap>?> getAsset(LoadAsset event) async {
    final ref = await collection()
        .where("assetCode", isEqualTo: event.assetCode)
        .limit(1)
        .get();
    return ref.docs.isEmpty
        ? null
        : _firestore.collection(path).doc(ref.docs.single.id);
  }
}
