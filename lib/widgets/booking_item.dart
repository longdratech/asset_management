import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../blocs/asset/asset_bloc.dart';
import '../blocs/asset/asset_event.dart';
import '../models/booking.dart';
import '../screens/booking/booking_request.dart';

class BookingItem extends StatefulWidget {
  final Booking booking;
  final ValueChanged<String> onChangedMember;
  final ValueChanged<String> onChangedNote;

  const BookingItem(
      {Key? key,
      required this.booking,
      required this.onChangedMember,
      required this.onChangedNote})
      : super(key: key);

  @override
  State<BookingItem> createState() => _BookingItemState();
}

class _BookingItemState extends State<BookingItem> {
  final _assetBloc = AssetBloc();

  bool _returned = false;

  @override
  void initState() {
    super.initState();
    _returned = widget.booking.endedAt != null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.network(
          'https://th.bing.com/th/id/OIP.45KbsvbD4r8MERxBWJbCgwHaHa?pid=ImgDet&rs=1',
          height: 100,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FutureBuilder(
                future: _assetBloc.getAssetById(
                  LoadAssetById(widget.booking.assetRef),
                ),
                builder: (context, snapshot) {
                  final state = snapshot.connectionState;
                  if (state == ConnectionState.done) {
                    final data = snapshot.data;
                    return Text(
                      "${data?.modelName != null && data?.modelName != "" ? data?.modelName : "N/A"} (${data?.assetCode != null && data?.assetCode != "" ? data!.assetCode : 'N/A'})",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return const Text('Loading...');
                },
              ),
              !_returned
                  ? const Text(
                      'Đang mượn',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      'Đã trả (${DateFormat('dd/MM/yyyy - HH:mm').format(widget.booking.endedAt!)})',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              Text(
                DateFormat('dd/MM/yyyy - HH:mm')
                    .format(widget.booking.createdAt),
              ),
              Row(
                children: [
                  Text(
                    widget.booking.employee,
                  ),
                  !_returned
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: GestureDetector(
                            onTap: () async {
                              final member = await showDialog(
                                context: context,
                                builder: (context) {
                                  return BookingRequest(
                                      widget.booking.employee);
                                },
                              );

                              if (member != null) {
                                widget.onChangedMember(member);
                              }
                            },
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
              Row(
                children: [
                  Text(
                    widget.booking.note != null && widget.booking.note != ""
                        ? widget.booking.note!
                        : _returned
                            ? "Không có ghi chú"
                            : "Thêm ghi chú",
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                  if (!_returned)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: GestureDetector(
                        onTap: () async {
                          final member = await showDialog(
                            context: context,
                            builder: (context) {
                              final controller = TextEditingController();
                              return AlertDialog(
                                title: const Text('Ghi chú'),
                                content: TextFormField(
                                  controller: controller,
                                ),
                                actions: [
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Hủy bỏ'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      widget.onChangedNote(controller.text);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Xác nhận'),
                                  )
                                ],
                              );
                            },
                          );

                          if (member != null) {
                            widget.onChangedMember(member);
                          }
                        },
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                        ),
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
