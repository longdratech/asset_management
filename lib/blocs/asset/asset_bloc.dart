import 'dart:async';

import 'package:assets_management/blocs/asset/asset_state.dart';
import 'package:assets_management/models/json_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<DocumentReference<JsonMap>?> getAsset(LoadAsset event) async {
    return await _repository.getAsset(event);
  }

  FutureOr<void> onAdd(AddAsset event) async {
    await _repository.addOne(
      Asset(
        assetCode: event.assetCode,
        modelName: event.modelName,
        serialNumber: event.serialNumber,
        type: event.type,
      ),
    );
  }

  FutureOr<void> _onLoadById(
    LoadAssetById event,
    Emitter<AssetState> emit,
  ) async {
    await emit.forEach(
      _repository.selectOne(event),
      onData: (data) {
        return AssetByIdLoaded(data);
      },
    );
  }
}
