import 'package:equatable/equatable.dart';
import 'package:assets_management/models/booking/booking.dart';

class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoaded extends BookingState {
  final List<Booking> booking;

  const BookingLoaded(this.booking);

  @override
  List<Object> get props => [booking];
}

class BookingStatus extends BookingState {
  final String status;

  const BookingStatus(this.status);

  @override
  List<Object> get props => [status];
}

class CheckBookingSuccess extends BookingState {}

class BookingFailure extends BookingState {}
