import 'package:assets_management/models/asset.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../blocs/asset/asset_event.dart';
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
    final split = event.documentId.split("/");
    return _firestore
        .doc(split.isNotEmpty ? event.documentId : "$path/${event.documentId}")
        .snapshots()
        .map((snapshot) {
      return Asset.fromFirestore(snapshot);
    });
  }

  Future<Asset> addOne(Asset asset) async {
    try {
      final added = await _firestore.collection(path).add(asset.toFirestore());
      return Asset.fromFirestore(await added.get());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOne(Asset asset) async {
    try {
      return await _firestore
          .collection(path)
          .doc(asset.id)
          .update(asset.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  Future<Asset> getAssetById(LoadAssetById event) async {
    final split = event.documentId.split("/");
    try {
      final asset = await _firestore
          .doc(
              split.isNotEmpty ? event.documentId : "$path/${event.documentId}")
          .snapshots()
          .first;
      return Asset.fromFirestore(asset);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Asset>?> getAssets(LoadAsset event) async {
    try {
      List<Asset> assets = [];
      final ref = await collection()
          .where('assetCode', isEqualTo: event.assetCode?.toUpperCase())
          .get();
      if (ref.docs.isNotEmpty) {
        for (final doc in ref.docs) {
          assets.add(
            Asset.fromFirestore(
              await _firestore.collection(path).doc(doc.id).get(),
            ),
          );
        }
        return assets;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
