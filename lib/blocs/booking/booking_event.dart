import 'package:assets_management/models/booking/booking.dart';
import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadBooking extends BookingEvent {
  const LoadBooking(this.createdAt);

  final DateTime createdAt;
}

class LoadBookingCompleted extends BookingEvent {
  const LoadBookingCompleted(this.data);

  final List<Booking> data;

  @override
  List<Object> get props => [data];
}

class AddBooking extends BookingEvent {}

class UpdateBooking extends BookingEvent {}

class RemoveBooking extends BookingEvent {}
