import 'dart:async';

import 'package:assets_management/blocs/booking/booking_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../enums/filter_booking.dart';
import '../../models/booking.dart';
import '../../repositories/booking_repository.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final _repository = BookingRepository();

  BookingBloc() : super(BookingInitial()) {
    on<LoadBooking>(_onLoad);
    on<ReqBooking>(_onReq);
    on<ReturnBooking>(_onReturn);
    on<TransferTo>(_onTransferTo);
  }

  Future<void> _onLoad(
    LoadBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    await emit.forEach<List<Booking>>(
      _repository.selectAll(event).map(
        (data) {
          final a = data.map((doc) {
            return Booking.fromDocumentSnapshot(doc);
          }).toList();
          if (event.filter == BookingOrderBy.notReturn) {
            a.sort((a, b) {
              if (a.endedAt != null && b.endedAt != null) {
                return b.endedAt!.compareTo(a.endedAt!);
              } else if (a.endedAt == null) {
                return -1;
              } else if (b.endedAt == null) {
                return 1;
              } else {
                return 0;
              }
            });
          }

          return a;
        },
      ),
      onData: (data) {
        return BookingLoaded(data);
      },
    );
  }

  Future<List<Booking>> getBooking(LoadBooking event) async {
    final data = await _repository
        .collectionByTime(event.createdAt)
        .where("asset", isEqualTo: "assets/${event.asset?.id}")
        .get();
    return data.docs.map((e) => Booking.fromDocumentSnapshot(e)).toList();
  }

  Future<Booking> _onReq(
    ReqBooking event,
    Emitter<BookingState> emit,
  ) async {
    return _repository.addOne(event);
  }

  FutureOr<void> _onReturn(
    ReturnBooking event,
    Emitter<BookingState> emit,
  ) async {
    _repository.collection().doc(event.id).update({"endedAt": event.endedAt});
  }

  FutureOr<void> _onTransferTo(
    TransferTo event,
    Emitter<BookingState> emit,
  ) async {
    await _onReturn(
      ReturnBooking(event.bookingId, endedAt: event.toCreatedAt),
      emit,
    );
    await _onReq(
      ReqBooking(
        assetRef: event.assetRef,
        name: event.member,
        createdAt: event.toCreatedAt,
      ),
      emit,
    );
  }
}
