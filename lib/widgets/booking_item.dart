import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../blocs/asset/asset_bloc.dart';
import '../blocs/asset/asset_event.dart';
import '../models/booking.dart';
import '../screens/booking/choose_member.dart';

class ItemBooking extends StatelessWidget {
  final _assetBloc = AssetBloc();

  final Booking booking;
  final ValueChanged<String> onChangedMember;

  ItemBooking({Key? key, required this.booking, required this.onChangedMember})
      : super(key: key);

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
                  LoadAssetById(booking.assetRef),
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
              booking.endedAt == null
                  ? const Text(
                      'Đang mượn',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      'Đã trả (${DateFormat('dd/MM/yyyy - HH:mm').format(booking.endedAt!)})',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              Text(
                DateFormat('dd/MM/yyyy - HH:mm').format(booking.createdAt),
              ),
              Row(
                children: [
                  Text(
                    booking.employee,
                  ),
                  booking.endedAt == null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: GestureDetector(
                            onTap: () async {
                              final member = await showDialog(
                                context: context,
                                builder: (context) {
                                  return const ChooseMember();
                                },
                              );

                              if (member != null) {
                                onChangedMember(member);
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
            ],
          ),
        ),
      ],
    );
  }
}
