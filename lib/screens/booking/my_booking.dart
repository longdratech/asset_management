import 'dart:io';

import 'package:assets_management/blocs/asset/asset_bloc.dart';
import 'package:assets_management/blocs/asset/asset_event.dart';
import 'package:assets_management/blocs/asset/asset_state.dart';
import 'package:assets_management/blocs/booking/booking_event.dart';
import 'package:assets_management/blocs/booking/booking_state.dart';
import 'package:assets_management/constants/routes.dart';
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
import '../../models/asset.dart';
import '../../repositories/firestore_repository.dart';
import '../assets/add_asset.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  late TextEditingController _controller;
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
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
                                    FutureBuilder(
                                      future: _assetBloc.getAssetById(
                                        LoadAssetById(data[i].assetRef),
                                      ),
                                      builder: (context, snapshot) {
                                        final state = snapshot.connectionState;
                                        if (state == ConnectionState.done) {
                                          final assetCode =
                                              snapshot.data!.assetCode;
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
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton(
                    heroTag: "text",
                    onPressed: () async {
                      if (!(Platform.isAndroid || Platform.isIOS)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please use smart phone')));
                      } else {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Nhập mã tài sản'),
                              content: TextField(
                                controller: _controller,
                              ),
                              actions: <Widget>[
                                TextButton(
                                  style: TextButton.styleFrom(
                                    textStyle:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    textStyle:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                  child: const Text('Xác nhận'),
                                  onPressed: () async {
                                    final assetCode = _controller.text;
                                    if (assetCode.isNotEmpty) {
                                      _process(_controller.text);
                                    }
                                    _controller.clear();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Icon(Icons.text_fields),
                  ),
                ),
                FloatingActionButton(
                  heroTag: "camera",
                  onPressed: () async {
                    try {
                      String assetCode =
                          await FlutterBarcodeScanner.scanBarcode(
                        '#ff6666',
                        'Cancel',
                        true,
                        ScanMode.QR,
                      );
                      if (assetCode != "-1") {
                        await _process(assetCode);
                      }
                    } on PlatformException {
                      print('failure scan');
                    }
                  },
                  child: const Icon(Icons.camera_alt_outlined),
                ),
              ],
            )),
      ),
    );
  }

  _process(String assetCode) async {
    // if (assetCode != "-1") {
    final asset = await _assetBloc.getAsset(
      LoadAsset(assetCode: assetCode),
    );

    if (asset != null) {
      final bookings = await _bloc.getBooking(
        LoadBooking(_current(_selectedIndex), asset: asset),
      );
      final noBookingInToday = bookings.isEmpty;

      if (noBookingInToday) {
        final member = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const ChooseMember();
          },
        );
        _bloc.add(
          ReqBooking(
            // createdAt: _current(_selectedIndex),
            name: member,
            assetRef: 'assets/${asset.id}',
          ),
        );
      } else {
        _bloc.add(
          ReturnBooking(
            bookings[0].id,
            endedAt: DateTime.now(),
          ),
        );
      }
    } else {
      final snackbar = SnackBar(
        content: Text(
            'Tài sản chưa tồn tại trong hệ thống. Chuyển tiếp sang trang thêm mới...'),
      );
      final show = ScaffoldMessenger.of(context).showSnackBar(snackbar);

      await Future.delayed(const Duration(milliseconds: 2000));
      show.close();

      final asset = await Navigator.pushNamed(
        context,
        addAsset,
        arguments: AddAssetArguments(assetCode),
      );

      if (asset != null) {
        final member = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ChooseMember();
          },
        );

        _bloc.add(
          ReqBooking(
            createdAt: _current(_selectedIndex),
            name: member,
            assetRef: 'assets/${(asset as Asset).id}',
          ),
        );
      }
    }
    // }
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
              bloc: _assetBloc..add(LoadAssetById(booking.assetRef)),
              builder: (context, state) {
                if (state is AssetLoading) {
                  return const Center(child: Text('Loading..'));
                } else if (state is AssetByLoaded) {
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
                _bloc.add(ReturnBooking(booking.id, endedAt: DateTime.now()));
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
