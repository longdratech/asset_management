import 'package:equatable/equatable.dart';

abstract class AssetEvent extends Equatable {
  const AssetEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssetById extends AssetEvent {
  final String documentId;

  const LoadAssetById(this.documentId);
}

class LoadAssetByRef extends AssetEvent {
  final String ref;

  const LoadAssetByRef(this.ref);
}

class LoadAsset extends AssetEvent {
  final String? assetCode;

  const LoadAsset({this.assetCode});
}

class AddAsset extends AssetEvent {
  final String assetCode;
  final String? modelName;
  final String? serialNumber;
  final String type;

  const AddAsset({
    required this.assetCode,
    required this.type,
    this.modelName,
    this.serialNumber,
  });
}

class RemoveAsset extends AssetEvent {}
