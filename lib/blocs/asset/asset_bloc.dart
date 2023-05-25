import 'dart:async';

import 'package:assets_management/blocs/asset/asset_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/asset.dart';
import '../../repositories/asset_repository.dart';
import 'asset_event.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final _repository = AssetRepository();

  AssetBloc() : super(AssetInitial()) {
    on<LoadAsset>(_onLoad);
    on<LoadAssetById>(_onLoadById);
    on<AddAsset>((event, emit) => onAdd(event));
  }

  Future<void> _onLoad(LoadAsset event, Emitter<AssetState> emit) async {
    emit(AssetLoading());
    await emit.forEach(
      _repository.selectAll(event),
      onData: (data) {
        return AssetLoaded(data);
      },
    );
  }

  Future<Asset> getAssetById(LoadAssetById event) async {
    return await _repository.getAssetById(event);
  }

  Future<List<Asset>?> getAssets(LoadAsset event) async {
    return await _repository.getAssets(event);
  }

  Future<Asset> onAdd(AddAsset event) async {
    return await _repository.addOne(
      Asset(
        assetCode: event.assetCode,
        modelName: event.modelName,
        serialNumber: event.serialNumber,
        type: event.type,
      ),
    );
  }

  Future<void> onUpdate(Asset event) async {
    return await _repository.updateOne(event);
  }

  FutureOr<void> _onLoadById(
    LoadAssetById event,
    Emitter<AssetState> emit,
  ) async {
    await emit.forEach(
      _repository.selectOne(event),
      onData: (data) {
        return AssetByLoaded(data);
      },
      onError: (err, stack) {
        return AssetFailure();
      },
    );
  }
}
