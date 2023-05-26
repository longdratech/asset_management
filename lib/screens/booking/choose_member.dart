import 'package:assets_management/blocs/%20members/member_bloc.dart';
import 'package:flutter/material.dart';

import '../../widgets/select_member.dart';

class ChooseMember extends StatefulWidget {
  const ChooseMember({Key? key}) : super(key: key);

  @override
  State<ChooseMember> createState() => _ChooseMemberState();
}

class _ChooseMemberState extends State<ChooseMember> {
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận mượn device'),
      content: SelectMember(
        hint: 'Chọn member',
        showAll: false,
        onChanged: (String member) {
          dropdownValue = member;
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
            if (dropdownValue == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng chọn người mượn')),
              );
            } else {
              Navigator.of(context).pop(dropdownValue);
            }
          },
        ),
      ],
    );
  }
}
