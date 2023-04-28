import 'dart:async';

import 'package:assets_management/blocs/%20members/member_event.dart';
import 'package:assets_management/blocs/%20members/member_state.dart';
import 'package:assets_management/models/member.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/member_repository.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final documents = 'members';

  final _repository = MemberRepository();

  MemberBloc() : super(MemberInitial()) {
    on<LoadMember>(_onLoad);
  }

  Future<void> _onLoad(LoadMember event, Emitter<MemberState> emit) async {
    await emit.forEach<List<Member>>(
      _repository.selectAll(),
      onData: (data) {
        return MemberLoaded(data);
      },
    );
  }
}
