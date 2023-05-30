import 'dart:async';

import 'package:assets_management/blocs/%20members/member_event.dart';
import 'package:assets_management/blocs/%20members/member_state.dart';
import 'package:assets_management/models/member.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../enums/role.dart';
import '../../repositories/member_repository.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final documents = 'members';

  final _repository = MemberRepository();

  MemberBloc() : super(MemberInitial()) {
    on<LoadMember>(_onLoad);
    on<LoadCurrentUser>(_onLoadCurrent);
  }

  Future<void> _onLoad(LoadMember event, Emitter<MemberState> emit) async {
    await emit.forEach<List<Member>>(
      _repository.selectAll(),
      onData: (data) {
        return MemberLoaded(data);
      },
    );
  }

  Future<void> _onLoadCurrent(event, Emitter<MemberState> emit) async {
    List<Member> members = [];

    await emit.forEach<User?>(
      _repository.currentUser(),
      onData: (data) {
        members.add(Member(
          name: data?.displayName ?? (data?.email ?? "N/A"),
          email: data?.email ?? "N/A",
        ));
        return MemberLoaded(members);
      },
      onError: (error, stackTrace) {
        return MemberFailure(
            (error as FirebaseAuthException).message ?? "Đã có lỗi xảy ra!");
      },
    );
  }

  Future<Member> getUser() async {
    try {
      return await _repository.getUser();
    } catch (e) {
      rethrow;
    }
  }
}
