import 'dart:async';

import 'package:assets_management/blocs/booking/booking_event.dart';
import 'package:assets_management/models/json_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/asset/asset_model.dart';
import '../../models/booking/booking.dart';
import '../../repositories/booking_repository.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final _repository = BookingRepository();

  BookingBloc() : super(BookingInitial()) {
    on<LoadBooking>(_onLoadBooking);
    on<CheckingBooking>(_onCheckingBooking);
  }

  Future<void> _onLoadBooking(
    LoadBooking event,
    Emitter<BookingState> emit,
  ) async {
    await emit.forEach<List<Booking>>(
      _repository.selectAll(datetime: event.createdAt).map(
        (data) {
          return data.map((doc) => Booking.fromDocumentSnapshot(doc)).toList();
        },
      ),
      onData: (data) {
        return BookingLoaded(data);
      },
    );
  }

  Future<void> _onCheckingBooking(
    CheckingBooking event,
    Emitter<BookingState> emit,
  ) async {
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
        .get();

    if (data.size > 0) {
      final bookings =
          data.docs.map((e) => Booking.fromDocumentSnapshot(e)).toList();
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
        "employee": "Test",
      });
    }
  }
}
