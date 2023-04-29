import 'package:equatable/equatable.dart';

import '../../models/asset.dart';
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
}

class AssetByIdLoaded extends AssetState {
  final Asset asset;

  const AssetByIdLoaded(this.asset);
}

class AssetAdded extends AssetState {
  const AssetAdded();
}

class AssetFailure extends AssetState {}
