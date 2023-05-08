import 'package:assets_management/blocs/%20members/member_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/ members/member_event.dart';
import '../../blocs/ members/member_state.dart';
import '../../models/member.dart';

class ChooseMember extends StatefulWidget {
  const ChooseMember({Key? key}) : super(key: key);

  @override
  State<ChooseMember> createState() => _ChooseMemberState();
}

class _ChooseMemberState extends State<ChooseMember> {
  String? dropdownValue;
  final _bloc = MemberBloc();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận mượn device'),
      content: BlocBuilder<MemberBloc, MemberState>(
        bloc: _bloc..add(LoadMember()),
        builder: (context, state) {
          if (state is MemberLoaded) {
            return DropdownButton<String>(
              value: dropdownValue ?? state.members.first.name,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? value) {
                if (value != null) {
                  String newValue = value;
                  setState(() {
                    dropdownValue = newValue;
                  });
                }
              },
              items:
                  state.members.map<DropdownMenuItem<String>>((Member member) {
                return DropdownMenuItem(
                  value: member.name,
                  child: Text(member.name),
                );
              }).toList(),
            );
          }
          return const Center(child: Text('Đã có lỗi xảy ra!'));
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          child: const Text('Xác nhận'),
          onPressed: () {
            Navigator.of(context).pop(dropdownValue);
          },
        ),
      ],
    );
  }
}
