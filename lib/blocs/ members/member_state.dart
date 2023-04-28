import 'package:equatable/equatable.dart';

import '../../models/member.dart';

class MemberState extends Equatable {
  const MemberState();

  @override
  List<Object?> get props => [];
}

class MemberInitial extends MemberState {}

class MemberLoaded extends MemberState {
  final List<Member> members;

  const MemberLoaded(this.members);

  @override
  List<Object> get props => [members];
}

class MemberFailure extends MemberState {
  final String error;

  const MemberFailure(this.error);
}
