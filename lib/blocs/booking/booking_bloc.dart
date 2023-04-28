import 'dart:async';

import 'package:assets_management/blocs/booking/booking_event.dart';
import 'package:assets_management/models/asset/asset_model.dart';
import 'package:assets_management/models/json_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking/booking.dart';
import '../../repositories/booking_repository.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final _repository = BookingRepository();

  BookingBloc() : super(BookingInitial()) {
    on<LoadBooking>(_onLoadBooking);
    on<ReqBooking>(_onReqBooking);
  }

  Future<void> _onLoadBooking(
    LoadBooking event,
    Emitter<BookingState> emit,
  ) async {
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

  Future<DocumentReference<Map<String, dynamic>>> getReference(
    ReqBooking event,
  ) async {
    final ref = await FirebaseFirestore.instance
        .collection('assets')
        .where("assetCode", isEqualTo: event.assetCode)
        .limit(1)
        .get();
    return FirebaseFirestore.instance
        .collection('assets')
        .doc(ref.docs.single.id);
  }

  Future<Asset> getAsset(String assetRef) async {
    final data =
        await FirebaseFirestore.instance.doc(assetRef).get();
    return Asset.fromFirestore(data);
  }

  Future<List<Booking>> onCheckingBooking(ReqBooking event) async {
    final start = DateTime(event.createdAt.year, event.createdAt.month,
        event.createdAt.day, 0, 0, 0);
    final end = DateTime(event.createdAt.year, event.createdAt.month,
        event.createdAt.day, 23, 59, 59);

    final ref = await FirebaseFirestore.instance
        .collection('assets')
        .where("assetCode", isEqualTo: event.assetCode)
        .limit(1)
        .get();
    final DocumentReference assetRef =
        FirebaseFirestore.instance.collection('assets').doc(ref.docs.single.id);

    final data = await FirebaseFirestore.instance
        .collection('booking')
        .where("asset", isEqualTo: assetRef)
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .get();

    return data.docs.map((e) => Booking.fromDocumentSnapshot(e)).toList();
  }

  Future<void> _onReqBooking(
    ReqBooking event,
    Emitter<BookingState> emit,
  ) async {
    final data = await onCheckingBooking(event);

    final assetRef = await getReference(event);

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
