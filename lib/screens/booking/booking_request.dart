import 'package:assets_management/blocs/%20members/member_bloc.dart';
import 'package:flutter/material.dart';

import '../../widgets/select_member.dart';

class BookingRequestArgs {
  final String member;
  final String? note;

  BookingRequestArgs(this.member, this.note);
}

class BookingRequest extends StatefulWidget {
  final String? initValue;

  const BookingRequest({Key? key, this.initValue}) : super(key: key);

  @override
  State<BookingRequest> createState() => _BookingRequestState();
}

class _BookingRequestState extends State<BookingRequest> {
  String? _initValue;

  late TextEditingController _noteController;

  @override
  void initState() {
    _initValue = widget.initValue;
    _noteController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận mượn device'),
      content: Column(
        children: [
          if (_initValue != null)
            Text(_initValue!)
          else
            SelectMember(
              hint: 'Chọn member',
              showAll: false,
              onChanged: (String member) {
                _initValue = member;
              },
            ),
          TextFormField(
            controller: _noteController,
            onTap: () {
              _noteController.text = "Kèm sạc";
            },
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: _noteController.clear,
                icon: const Icon(Icons.clear),
              ),
              labelText: 'Ghi chú',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          child: const Text('Xác nhận'),
          onPressed: () {
            if (_initValue == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng chọn người mượn')),
              );
            } else {
              Navigator.of(context).pop(BookingRequestArgs(_initValue!, _noteController.text));
            }
          },
        ),
      ],
    );
  }
}
