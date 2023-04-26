import 'package:assets_management/blocs/booking/booking_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking/booking.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/firestore_repository.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final _repository = BookingRepository();

  BookingBloc() : super(BookingInitial()) {
    on<LoadBooking>(_onLoadBooking);
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

  Future<void> _onLoadCompletion(
    LoadBookingCompleted event,
    Emitter<BookingState> emit,
  ) async {
    // emit(state.copyWith(status: () => BookingStateStatus.success));
  }
}
