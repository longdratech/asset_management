import 'package:assets_management/blocs/asset/asset_bloc.dart';
import 'package:assets_management/blocs/asset/asset_event.dart';
import 'package:assets_management/blocs/asset/asset_state.dart';
import 'package:assets_management/blocs/booking/booking_event.dart';
import 'package:assets_management/blocs/booking/booking_state.dart';
import 'package:assets_management/models/booking.dart';
import 'package:assets_management/screens/booking/choose_member.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/booking/booking_bloc.dart';
import '../../models/json_map.dart';
import '../../repositories/firestore_repository.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final repository = FirestoreRepository();
  final _bloc = BookingBloc();
  final _assetBloc = AssetBloc();

  final datetime = List.generate(10, (index) {
    return DateTime.now()
        .subtract(const Duration(days: 9))
        .add(Duration(days: index));
  }).map((e) {
    return DateFormat('dd/MM/yyyy').format(e);
  }).toList();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        datetime.indexOf(DateFormat('dd/MM/yyyy').format(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: _selectedIndex,
      length: datetime.length,
      child: BlocProvider(
        create: (context) => _bloc..add(LoadBooking(DateTime.now())),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                onTap: (index) {
                  _selectedIndex = index;
                  _bloc.add(LoadBooking(_current(index)));
                },
                tabs: datetime.map(
                  (e) {
                    return Tab(
                      child: Text(e),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () {
              _bloc.add(LoadBooking(_current(_selectedIndex)));
              return Future<void>.delayed(const Duration(seconds: 0));
            },
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                if (state is BookingLoading) {
                  return const Center(child: Text('Loading...'));
                } else if (state is BookingLoaded) {
                  final data = state.booking;
                  if (data.isEmpty) {
                    return const Center(child: Text('No data!'));
                  } else {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: GestureDetector(
                              onTap: () {
                                _showMyDialog(data[i]);
                              },
                              child: ListBody(
                                children: <Widget>[
                                  BlocBuilder<AssetBloc, AssetState>(
                                    bloc: _assetBloc
                                      ..add(
                                        LoadAssetById(data[i].asset.id),
                                      ),
                                    builder: (context, state) {
                                      if (state is AssetByIdLoaded) {
                                        final assetCode = state.asset.assetCode;
                                        return Text.rich(
                                          TextSpan(
                                            text: 'Asset code: ',
                                            children: [
                                              TextSpan(
                                                text: assetCode,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return const Text('Loading...');
                                    },
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      text: 'Trạng thái: ',
                                      children: [
                                        data[i].endedAt == null
                                            ? const TextSpan(
                                                text: 'Đang mượn',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : TextSpan(
                                                text:
                                                    'Đã trả (${DateFormat('dd/MM/yyyy - HH:mm').format(data[i].endedAt!)})',
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "Thời gian mượn: ${DateFormat('dd/MM/yyyy - HH:mm').format(data[i].createdAt)}",
                                  ),
                                  Text("Người mượn:  ${data[i].employee}"),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                } else {
                  return const Center(
                    child: Text(
                      'Đã có lỗi xảy ra. Vui lòng liên hệ LongTH20!',
                    ),
                  );
                }
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              try {
                String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                  '#ff6666',
                  'Cancel',
                  true,
                  ScanMode.QR,
                );
                final assetCode = barcodeScanRes;

                final onCheck = await _bloc.onCheckingBooking(ReqBooking(
                  createdAt: _current(_selectedIndex),
                  assetCode: assetCode,
                ));
                final member = onCheck.isEmpty
                    ? await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ChooseMember();
                        },
                      )
                    : null;
                _bloc.add(
                  ReqBooking(
                    createdAt: DateFormat('dd/MM/yyyy').parse(
                      datetime[_selectedIndex],
                    ),
                    assetCode: assetCode,
                    name: member,
                  ),
                );
              } on PlatformException {
                print('failure scan');
              }
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  _showMyDialog(Booking booking) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận trả device'),
          content: SingleChildScrollView(
            child: BlocBuilder<AssetBloc, AssetState>(
              bloc: _assetBloc..add(LoadAssetById(booking.asset.id)),
              builder: (context, state) {
                if (state is AssetLoading) {
                  return const Center(child: Text('Loading..'));
                } else if (state is AssetByIdLoaded) {
                  final asset = state.asset;
                  final picSize = asset.pictures?.length ?? 0;

                  return ListBody(
                    children: [
                      picSize > 0
                          ? CarouselSlider.builder(
                              itemCount: picSize,
                              itemBuilder: (context, itemIndex, pageViewIndex) {
                                return Image(
                                  image:
                                      NetworkImage(asset.pictures![itemIndex]),
                                );
                              },
                              options: CarouselOptions(
                                autoPlay: false,
                                enlargeCenterPage: true,
                                viewportFraction: 0.9,
                                aspectRatio: 2.0,
                                initialPage: picSize,
                              ),
                            )
                          : const Text(
                              'No Picture!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                      Text('Asset code: ${asset.assetCode}'),
                      Text('Model name: ${asset.modelName}'),
                      Text('Serial number: ${asset.serialNumber}'),
                      Text('Loại: ${asset.type}'),
                    ],
                  );
                }
                return const Center(
                  child: Text(
                    'Đã có lỗi xảy ra. Vui lòng liên hệ LongTH20 để được hỗ trợ!',
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              child: const Text('Xác nhận'),
              onPressed: () {
                firestore.collection('booking').doc(booking.id).update({
                  "endedAt": DateTime.now(),
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  DateTime _current(index) {
    return DateFormat('dd/MM/yyyy').parse(datetime[index]);
  }
}
