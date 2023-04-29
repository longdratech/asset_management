import 'package:equatable/equatable.dart';
import 'package:assets_management/models/booking.dart';

class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<Booking> booking;

  const BookingLoaded(this.booking);

  @override
  List<Object> get props => [booking];
}


class BookingFailure extends BookingState {}
