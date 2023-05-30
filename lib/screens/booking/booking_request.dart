import 'package:flutter/material.dart';

import '../../widgets/select_member.dart';

class BookingRequest extends StatefulWidget {
  final String initValue;
  final bool? isShowSelect;

  const BookingRequest(this.initValue, {Key? key, this.isShowSelect})
      : super(key: key);

  @override
  State<BookingRequest> createState() => _BookingRequestState();
}

class _BookingRequestState extends State<BookingRequest> {
  String? member;

  @override
  void initState() {
    super.initState();
    member = widget.initValue;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận mượn device'),
      content: (widget.isShowSelect == false)
          ? Text(widget.initValue)
          : SelectMember(
              hint: 'Chọn member',
              showAll: false,
              onChanged: (String member) {
                member = member;
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
            if (member == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng chọn người mượn')),
              );
            } else {
              Navigator.of(context).pop(member);
            }
          },
        ),
      ],
    );
  }
}
