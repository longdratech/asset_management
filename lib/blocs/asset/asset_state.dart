import 'package:equatable/equatable.dart';

import '../../models/asset.dart';

class AssetState extends Equatable {
  const AssetState();

  @override
  List<Object?> get props => [];
}

class AssetInitial extends AssetState {}

class AssetLoading extends AssetState {}

class AssetLoaded extends AssetState {
  final List<Asset> assets;

  const AssetLoaded(this.assets);

  @override
  List<Object> get props => [assets];
}

class AssetByLoaded extends AssetState {
  final Asset asset;

  const AssetByLoaded(this.asset);
}

class AssetAdded extends AssetState {
  final Asset asset;

  const AssetAdded(this.asset);
}

class AssetFailure extends AssetState {
  final String error;

  const AssetFailure(this.error);
}
