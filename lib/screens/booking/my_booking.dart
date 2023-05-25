import 'dart:io';

import 'package:assets_management/blocs/asset/asset_bloc.dart';
import 'package:assets_management/blocs/asset/asset_event.dart';
import 'package:assets_management/blocs/asset/asset_state.dart';
import 'package:assets_management/blocs/booking/booking_event.dart';
import 'package:assets_management/blocs/booking/booking_state.dart';
import 'package:assets_management/constants/routes.dart';
import 'package:assets_management/enums/filter_booking.dart';
import 'package:assets_management/models/booking.dart';
import 'package:assets_management/models/filter.dart';
import 'package:assets_management/screens/booking/choose_member.dart';
import 'package:assets_management/widgets/asset_item.dart';
import 'package:assets_management/widgets/booking_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

import '../../blocs/booking/booking_bloc.dart';
import '../../constants/bookings_filter.dart';
import '../../models/asset.dart';
import '../../repositories/firestore_repository.dart';
import '../assets/add_asset.dart';

enum Categories { Laptop, Camera, Lens, Adapter, Hub }

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  late TextEditingController _controller;
  Filter _filterItem = bookingFilters[0];

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
  Set<Categories> selection = <Categories>{
    Categories.Laptop,
    Categories.Camera,
    Categories.Adapter
  };

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
        create: (context) => _bloc
          ..add(LoadBooking(
            DateTime.now(),
            filter: _filterItem.value,
          )),
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              scrolledUnderElevation: 5,
              shadowColor: Colors.grey,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(30),
                child: TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  onTap: (index) {
                    _selectedIndex = index;
                    _bloc.add(LoadBooking(
                      _current(index),
                      filter: _filterItem.value,
                    ));
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
            body: Scaffold(
              appBar: AppBar(
                title: Align(
                  alignment: Alignment.topRight,
                  child: DropdownButton<Filter>(
                    value: _filterItem,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (Filter? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        _filterItem = value!;
                      });
                      _bloc.add(LoadBooking(
                        _current(_selectedIndex),
                        filter: _filterItem.value,
                      ));
                    },
                    items: bookingFilters
                        .map<DropdownMenuItem<Filter>>((Filter filter) {
                      return DropdownMenuItem<Filter>(
                        value: filter,
                        child: Text(filter.label),
                      );
                    }).toList(),
                  ),
                ),
              ),
              body: BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  if (state is BookingLoading) {
                    return const Center(child: Text('Loading...'));
                  } else if (state is BookingLoaded) {
                    final data = state.booking;
                    if (data.isEmpty) {
                      return const Center(child: Text('No data!'));
                    } else {
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int i) {
                          return GestureDetector(
                            onTap: () {
                              _showConfirmed(data[i]);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    top: 20,
                                    right: 20,
                                  ),
                                  child: ItemBooking(
                                    booking: data[i],
                                    onChangedMember: (member) {
                                      _bloc.add(
                                        TransferTo(
                                          data[i].id,
                                          data[i].assetRef,
                                          member,
                                          DateTime.now(),
                                        ),
                                      );
                                    },
                                  ),
                                  // child: Row(
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.start,
                                  //   mainAxisAlignment: MainAxisAlignment.start,
                                  //   mainAxisSize: MainAxisSize.min,
                                  //   children: [
                                  //     Image.network(
                                  //       'https://th.bing.com/th/id/OIP.45KbsvbD4r8MERxBWJbCgwHaHa?pid=ImgDet&rs=1',
                                  //       height: 100,
                                  //     ),
                                  //     Padding(
                                  //       padding:
                                  //           const EdgeInsets.only(left: 10),
                                  //       child: Column(
                                  //         crossAxisAlignment:
                                  //             CrossAxisAlignment.start,
                                  //         children: <Widget>[
                                  //           FutureBuilder(
                                  //             future: _assetBloc.getAssetById(
                                  //               LoadAssetById(data[i].assetRef),
                                  //             ),
                                  //             builder: (context, snapshot) {
                                  //               final state =
                                  //                   snapshot.connectionState;
                                  //               if (state ==
                                  //                   ConnectionState.done) {
                                  //                 final assetCode =
                                  //                     snapshot.data!.assetCode;
                                  //                 return Text(
                                  //                   assetCode,
                                  //                   overflow:
                                  //                       TextOverflow.ellipsis,
                                  //                   style: const TextStyle(
                                  //                     fontWeight:
                                  //                         FontWeight.bold,
                                  //                   ),
                                  //                 );
                                  //               }
                                  //               return const Text('Loading...');
                                  //             },
                                  //           ),
                                  //           data[i].endedAt == null
                                  //               ? const Text(
                                  //                   'Đang mượn',
                                  //                   style: TextStyle(
                                  //                     color: Colors.red,
                                  //                     fontWeight:
                                  //                         FontWeight.bold,
                                  //                   ),
                                  //                 )
                                  //               : Text(
                                  //                   'Đã trả (${DateFormat('dd/MM/yyyy - HH:mm').format(data[i].endedAt!)})',
                                  //                   style: const TextStyle(
                                  //                     color: Colors.green,
                                  //                     fontWeight:
                                  //                         FontWeight.bold,
                                  //                   ),
                                  //                 ),
                                  //           Text(
                                  //             DateFormat('dd/MM/yyyy - HH:mm')
                                  //                 .format(data[i].createdAt),
                                  //           ),
                                  //           Row(
                                  //             children: [
                                  //               Text(
                                  //                 data[i].employee,
                                  //               ),
                                  //               data[i].endedAt == null
                                  //                   ? Padding(
                                  //                       padding:
                                  //                           const EdgeInsets
                                  //                               .only(left: 6),
                                  //                       child: GestureDetector(
                                  //                         onTap: () async {
                                  //                           final member =
                                  //                               await showDialog(
                                  //                             context: context,
                                  //                             builder:
                                  //                                 (context) {
                                  //                               return const ChooseMember();
                                  //                             },
                                  //                           );
                                  //                           _bloc.add(TransferTo(data[i].id, data[i].assetRef, member, DateTime.now()));
                                  //                         },
                                  //                         child: const Icon(
                                  //                           Icons.edit,
                                  //                           size: 18,
                                  //                         ),
                                  //                       ),
                                  //                     )
                                  //                   : Container()
                                  //             ],
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ),
                                i + 1 != data.length
                                    ? Divider(height: 0.5)
                                    : Container(),
                              ],
                            ),
                          );
                        },
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
    final assets = await _assetBloc.getAssets(
      LoadAsset(assetCode: assetCode.toUpperCase()),
    );

    if (assets != null) {
      final asset = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Chọn asset'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, assets[index]);
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: AssetItem(asset: assets[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      if (asset != null) {
        final bookings = await _bloc.getBooking(
          LoadBooking(
            _current(_selectedIndex),
            asset: asset,
            filter: _filterItem.value,
          ),
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
              name: member,
              assetRef: !kReleaseMode
                  ? 'assets-dev/${asset.id}'
                  : 'assets/${asset.id}',
            ),
          );
        } else {
          _showConfirmed(bookings[0]);
        }
      }
    } else {
      final snackbar = SnackBar(
        content: Text(
          'Tài sản chưa tồn tại trong hệ thống. Vui lòng thêm mới...',
        ),
        duration: Duration(milliseconds: 1500),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);

      final asset = await Navigator.pushNamed(
        context,
        addAsset,
        arguments: AddAssetArguments(Asset(assetCode: assetCode)),
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
            name: member,
            assetRef: !kReleaseMode
                ? 'assets-dev/${(asset as Asset).id}'
                : 'assets/${(asset as Asset).id}',
          ),
        );
      }
    }
  }

  _showConfirmed(Booking booking) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận"),
          content: SingleChildScrollView(
            child: BlocBuilder<AssetBloc, AssetState>(
              bloc: _assetBloc..add(LoadAssetById(booking.assetRef)),
              builder: (context, state) {
                if (state is AssetLoading) {
                  return const Center(child: Text('Loading..'));
                } else if (state is AssetByLoaded) {
                  final asset = state.asset;

                  return AssetItem(asset: asset);
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            booking.endedAt == null
                ? TextButton(
                    onPressed: () {
                      _bloc.add(TransferTo(
                        booking.id,
                        booking.assetRef,
                        booking.employee,
                        DateTime.now(),
                      ));
                      Navigator.pop(context);
                    },
                    child: const Text('Next day'),
                  )
                : Container(),
            TextButton(
              child: Text(booking.endedAt == null ? 'Trả' : 'Huỷ Trả'),
              onPressed: () {
                _bloc.add(ReturnBooking(
                  booking.id,
                  endedAt: booking.endedAt == null ? DateTime.now() : null,
                ));
                Navigator.pop(context);
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
