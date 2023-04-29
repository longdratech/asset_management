import 'package:assets_management/blocs/%20members/member_bloc.dart';
import 'package:assets_management/blocs/%20members/member_event.dart';
import 'package:assets_management/blocs/asset/asset_bloc.dart';
import 'package:assets_management/blocs/asset/asset_event.dart';
import 'package:assets_management/blocs/asset/asset_state.dart';
import 'package:assets_management/blocs/booking/booking_event.dart';
import 'package:assets_management/blocs/booking/booking_state.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/ members/member_state.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../../models/asset.dart';
import '../../models/json_map.dart';
import '../../models/member.dart';
import '../../repositories/firestore_repository.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String dropdownValue = '';

  final repository = FirestoreRepository();
  final _bloc = BookingBloc();
  final _memberBloc = MemberBloc();
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
              preferredSize: Size.fromHeight(30),
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
                          return TextButton(
                            onPressed: () => _showMyDialog(data[i].id),
                            child: ListBody(
                              children: <Widget>[
                                BlocBuilder<AssetBloc, AssetState>(
                                  bloc: _assetBloc
                                    ..add(LoadAssetById(data[i].asset.id)),
                                  builder: (context, state) {
                                    if (state is AssetByIdLoaded) {
                                      final assetCode = state.asset.assetCode;
                                      return Text(
                                        'Asset code: $assetCode',
                                      );
                                    }
                                    return const Text('Loading...');
                                  },
                                ),
                                Text("Thời gian mượn: ${data[i].createdAt}"),
                                Text("Người mượn:  ${data[i].employee}"),
                                Text(
                                    "Trạng thái:  ${data[i].endedAt == null ? 'Đang mượn' : 'Đã trả (${DateFormat('dd/MM/yyyy - HH:mm').format(data[i].endedAt!)})'}"),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                } else {
                  return Text('Fail');
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
                if (onCheck.isEmpty) {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return BlocProvider(
                        create: (context) => _memberBloc..add(LoadMember()),
                        child: AlertDialog(
                          title: const Text('Xác nhận muợn device'),
                          content: BlocBuilder<MemberBloc, MemberState>(
                            builder: (context, state) {
                              if (state is MemberLoaded) {
                                dropdownValue = state.members.first.name;

                                return DropdownButton<String>(
                                  value: dropdownValue,
                                  icon: const Icon(Icons.arrow_downward),
                                  elevation: 16,
                                  style:
                                      const TextStyle(color: Colors.deepPurple),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String? value) {
                                    setState(() {
                                      dropdownValue = value!;
                                    });
                                    print("member select ${value}");
                                  },
                                  items: state.members
                                      .map<DropdownMenuItem<String>>(
                                          (Member member) {
                                    return DropdownMenuItem(
                                      value: member.name,
                                      child: Text(member.name),
                                    );
                                  }).toList(),
                                );
                              }
                              return Text('Đã có lỗi xảy ra!');
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              child: const Text('Xác nhận'),
                              onPressed: () {
                                _bloc.add(
                                  ReqBooking(
                                    createdAt: DateFormat('dd/MM/yyyy').parse(
                                      datetime[_selectedIndex],
                                    ),
                                    assetCode: assetCode,
                                    name: dropdownValue,
                                  ),
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  _bloc.add(
                    ReqBooking(
                      createdAt: DateFormat('dd/MM/yyyy').parse(
                        datetime[_selectedIndex],
                      ),
                      assetCode: assetCode,
                      name: dropdownValue,
                    ),
                  );
                }
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

  _showMyDialog(String bookingId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận trả device'),
          content: SingleChildScrollView(
            child: StreamBuilder(
              stream:
                  firestore.collection('booking').doc(bookingId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                final data = snapshot.data?.data();
                final assetRef = data?['asset'] as DocumentReference;

                return StreamBuilder(
                  stream: assetRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading..');
                    }
                    final data = snapshot.data!.data() as JsonMap;
                    final assetCode = data['assetCode'];
                    final modelName = data['modelName'];
                    final serialNumber = data['serialNumber'];
                    final pictures = data['pictures'];
                    final type = data['type'];

                    return ListBody(
                      children: <Widget>[
                        CarouselSlider.builder(
                          itemCount: pictures.length,
                          itemBuilder: (context, itemIndex, pageViewIndex) {
                            return Image(
                              image: NetworkImage(pictures[itemIndex]),
                            );
                          },
                          options: CarouselOptions(
                            autoPlay: false,
                            enlargeCenterPage: true,
                            viewportFraction: 0.9,
                            aspectRatio: 2.0,
                            initialPage: 2,
                          ),
                        ),
                        Text('Asset code: $assetCode'),
                        Text('Model name: $modelName'),
                        Text('Serial number: $serialNumber'),
                        Text('Loại: $type'),
                      ],
                    );
                  },
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
                firestore.collection('booking').doc(bookingId).update({
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
