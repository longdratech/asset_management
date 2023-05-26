import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/ members/member_bloc.dart';
import '../blocs/ members/member_event.dart';
import '../blocs/ members/member_state.dart';

class SelectMember extends StatefulWidget {
  final String hint;
  final bool showAll;
  final ValueChanged<String> onChanged;

  const SelectMember({
    Key? key,
    required this.hint,
    required this.showAll,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SelectMember> createState() => _SelectMemberState();
}

class _SelectMemberState extends State<SelectMember> {
  String? dropdownValue;
  late MemberBloc _bloc;

  @override
  void initState() {
    _bloc = MemberBloc();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberBloc, MemberState>(
      bloc: _bloc..add(LoadMember()),
      builder: (context, state) {
        if (state is MemberLoaded) {
          final members = state.members.map((e) => e.name).toList();
          if (widget.showAll) {
            members.add("All");
          }
          return DropdownButton<String>(
            value: dropdownValue,
            hint: Text(widget.hint),
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  dropdownValue = value;
                });

                widget.onChanged(value == "All" ? '' : value);
              }
            },
            items: members.map<DropdownMenuItem<String>>((String member) {
              return DropdownMenuItem(
                value: member,
                child: Text(member),
              );
            }).toList(),
          );
        }
        return const Center(child: Text('Đã có lỗi xảy ra!'));
      },
    );
  }
}
