import 'dart:async';

import 'package:assets_management/blocs/asset/asset_event.dart';
import 'package:assets_management/blocs/booking/booking_event.dart';
import 'package:assets_management/models/asset.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking.dart';
import '../../repositories/asset_repository.dart';
import '../../repositories/booking_repository.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final _repository = BookingRepository();
  final _assetRepository = AssetRepository();

  BookingBloc() : super(BookingInitial()) {
    on<LoadBooking>(_onLoad);
    on<ReqBooking>(_onReq);
  }

  Future<void> _onLoad(
    LoadBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    await emit.forEach<List<Booking>>(
      _repository.selectAll(datetime: event.createdAt).map(
        (data) {
          return data.map((doc) {
            return Booking.fromDocumentSnapshot(doc);
          }).toList();
        },
      ),
      onData: (data) {
        return BookingLoaded(data);
      },
    );
  }

  Future<List<Booking>> onCheckingBooking(ReqBooking event) async {
    final start = DateTime(event.createdAt.year, event.createdAt.month,
        event.createdAt.day, 0, 0, 0);
    final end = DateTime(event.createdAt.year, event.createdAt.month,
        event.createdAt.day, 23, 59, 59);

    final assetRef = await _assetRepository.getAsset(
      LoadAsset(assetCode: event.assetCode),
    );

    final data = await FirebaseFirestore.instance
        .collection('booking')
        .where("asset", isEqualTo: assetRef)
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .get();

    return data.docs.map((e) => Booking.fromDocumentSnapshot(e)).toList();
  }

  Future<void> _onReq(
    ReqBooking event,
    Emitter<BookingState> emit,
  ) async {
    final data = await onCheckingBooking(event);

    final assetRef = await _assetRepository.getAsset(
      LoadAsset(assetCode: event.assetCode),
    );

    if (data.isNotEmpty) {
      final bookings = data;
      for (final booking in bookings) {
        FirebaseFirestore.instance
            .collection('booking')
            .doc(booking.id)
            .update({"endedAt": Timestamp.now()});
      }
    } else {
      FirebaseFirestore.instance.collection('booking').add({
        "asset": assetRef,
        "createdAt": Timestamp.now(),
        "employee": event.name,
        "endedAt": null
      });
    }
  }
}
