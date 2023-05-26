import 'dart:async';

import 'package:assets_management/blocs/asset/asset_state.dart';
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
    await emit.forEach(_repository.selectAll(event), onData: (data) {
      return AssetLoaded(data);
    }, onError: (error, stackTrace) {
      return AssetFailure((error as FirebaseException).message?? 'Đã có lỗi xảy ra!');
    });
  }

  Future<Asset> getAssetById(LoadAssetById event) async {
    try {
      return await _repository.getAssetById(event);
    } catch (e) {
      throw (e as FirebaseException).message ?? 'Đã có lỗi xảy ra!';
    }
  }

  Future<List<Asset>?> getAssets(LoadAsset event) async {
    try {
      return await _repository.getAssets(event);
    } catch (e) {
      throw (e as FirebaseException).message ?? 'Đã có lỗi xảy ra!';
    }
  }

  Future<Asset> onAdd(AddAsset event) async {
    try {
      return await _repository.addOne(
        Asset(
          assetCode: event.assetCode,
          modelName: event.modelName,
          serialNumber: event.serialNumber,
          type: event.type,
        ),
      );
    } catch (e) {
      throw (e as FirebaseException).message ?? 'Đã có lỗi xảy ra!';
    }
  }

  Future<void> onUpdate(Asset event) async {
    try {
      return await _repository.updateOne(event);
    } catch (e) {
      throw (e as FirebaseException).message ?? 'Đã có lỗi xảy ra!';
    }
  }

  Future<void> onRemoveOne(String id) async {
    try {
      return await _repository.removeOne(id);
    } catch (e) {
      throw (e as FirebaseException).message ?? 'Đã có lỗi xảy ra!';
    }
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
      onError: (e, stack) {
        return AssetFailure(
            (e as FirebaseException).message ?? 'Đã có lỗi xảy ra!');
      },
    );
  }
}
