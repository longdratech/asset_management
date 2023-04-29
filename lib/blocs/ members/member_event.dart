import 'package:assets_management/models/member.dart';
import 'package:equatable/equatable.dart';

abstract class MemberEvent extends Equatable {
  const MemberEvent();

  @override
  List<Object?> get props => [];
}

class LoadMember extends MemberEvent {}

class AddMember extends MemberEvent {
  final String name;

  const AddMember(this.name);
}

class UpdateMember extends MemberEvent {
  final String name;

  const UpdateMember(this.name);
}

class RemoveMember extends MemberEvent {}
