import 'package:assets_management/models/booking.dart';
import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookingById extends BookingEvent {
  final String documentId;

  const LoadBookingById(this.documentId);
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

class ReqBooking extends BookingEvent {
  const ReqBooking({
    required this.createdAt,
    required this.assetCode,
    this.name,
  });

  final DateTime createdAt;
  final String assetCode;
  final String? name;

  @override
  List<Object> get props => [createdAt, assetCode];
}

class RemoveBooking extends BookingEvent {}
