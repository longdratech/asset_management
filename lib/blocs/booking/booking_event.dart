import 'package:assets_management/models/asset.dart';
import 'package:assets_management/models/booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  const LoadBooking(this.createdAt, {this.asset});

  final DateTime createdAt;
  final Asset? asset;
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
    required this.assetRef,
    required this.name,
    this.createdAt,
  });

  final DateTime? createdAt;
  final String assetRef;
  final String name;
}

class ReturnBooking extends BookingEvent {
  final String id;
  final DateTime? endedAt;

  const ReturnBooking(this.id, {this.endedAt});
}

class TransferTo extends BookingEvent {
  final String bookingId;
  final String assetRef;
  final String member;
  final DateTime toCreatedAt;

  const TransferTo(this.bookingId, this.assetRef, this.member, this.toCreatedAt);
}

class RemoveBooking extends BookingEvent {}
