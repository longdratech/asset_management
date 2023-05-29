import 'package:assets_management/blocs/%20members/member_bloc.dart';
import 'package:assets_management/blocs/asset/asset_bloc.dart';
import 'package:assets_management/blocs/asset/asset_event.dart';
import 'package:assets_management/blocs/asset/asset_state.dart';
import 'package:assets_management/blocs/booking/booking_event.dart';
import 'package:assets_management/blocs/booking/booking_state.dart';
import 'package:assets_management/constants/routes.dart';
import 'package:assets_management/models/booking.dart';
import 'package:assets_management/models/filter.dart';
import 'package:assets_management/screens/booking/booking_request.dart';
import 'package:assets_management/widgets/asset_item.dart';
import 'package:assets_management/widgets/booking_item.dart';
import 'package:assets_management/widgets/newest_filter.dart';
import 'package:assets_management/widgets/select_member.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/booking/booking_bloc.dart';
import '../../constants/bookings_filter.dart';
import '../../models/asset.dart';
import '../../repositories/firestore_repository.dart';
import '../assets/add_asset.dart';

class MyBooking extends StatefulWidget {
  const MyBooking({super.key});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  late TextEditingController _controller;
  final Filter _filterItem = bookingFilters[0];
  String _filterByName = '';
  User? _user;
  bool _isAdmin = false;

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
    _controller = TextEditingController();

    _user = _memberBloc.getUser();

    /// FIXME: fix hard code
    _isAdmin = _user?.email == "1tranhuulong131@gmail.com";
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
                    member: _filterByName,
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
                child: Wrap(
                  direction: Axis.horizontal,
                  runSpacing: 20,
                  spacing: 20,
                  children: [
                    SelectMember(
                      hint: 'Lọc theo tên',
                      showAll: true,
                      onChanged: (String member) {
                        _filterByName = member;
                        _bloc.add(LoadBooking(
                          _current(_selectedIndex),
                          filter: _filterItem.value,
                          member: _filterByName,
                        ));
                      },
                    ),
                    NewestFilter(onChanged: (value) {
                      _bloc.add(LoadBooking(
                        _current(_selectedIndex),
                        filter: _filterItem.value,
                      ));
                    }),
                  ],
                ),
              ),
            ),
            body: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                if (state is BookingLoading) {
                  return const Center(child: Text('Loading...'));
                } else if (state is BookingFailure) {
                  return Center(child: Text(state.error));
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
                                child: BookingItem(
                                  booking: data[i],
                                  onChangedMember: (member) {
                                    _bloc.onTransferTo(TransferTo(
                                      data[i].id,
                                      data[i].assetRef,
                                      member,
                                      DateTime.now(),
                                    ));
                                  },
                                ),
                              ),
                              i + 1 != data.length
                                  ? const Divider(height: 0.5)
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
                      'Đã có lỗi xảy ra!',
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
                  heroTag: "text1",
                  onPressed: () {
                    showDialog(
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
                              onPressed: () {
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
                  },
                  child: const Icon(kIsWeb ? Icons.add : Icons.text_fields),
                ),
              ),
              if (!kIsWeb)
                FloatingActionButton(
                  heroTag: "camera1",
                  onPressed: () {
                    FlutterBarcodeScanner.scanBarcode(
                      '#ff6666',
                      'Cancel',
                      true,
                      ScanMode.QR,
                    ).then((value) {
                      if (value != "-1") {
                        _process(value);
                      }
                    });
                  },
                  child: const Icon(Icons.camera_alt_outlined),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _process(String assetCode) {
    _assetBloc
        .getAssets(
      LoadAsset(
        assetCode: assetCode.toUpperCase(),
      ),
    )
        .catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }).then((assets) {
      if (assets != null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Chọn asset'),
              content: SizedBox(
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
        ).then((asset) {
          if (asset != null) {
            _bloc
                .getBooking(
              LoadBooking(
                _current(_selectedIndex),
                asset: asset,
                filter: _filterItem.value,
              ),
            )
                .then((bookings) async {
              final noBookingInToday = bookings.isEmpty;

              if (noBookingInToday) {
                final BookingRequestArgs res = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final initValue = !_isAdmin ? _user?.email : null;
                    return BookingRequest(initValue: initValue);
                  },
                );
                _bloc
                    .onReq(ReqBooking(
                  name: res.member,
                  assetRef: !kReleaseMode
                      ? 'assets-dev/${asset.id}'
                      : 'assets/${asset.id}',
                  note: res.note
                ))
                    .catchError((err) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(err)));
                });
              } else {
                _showConfirmed(bookings[0]);
              }
            });
          }
        });
      } else {
        const snackBar = SnackBar(
          content: Text(
            'Tài sản chưa tồn tại trong hệ thống. Vui lòng thêm mới...',
          ),
          duration: Duration(milliseconds: 1500),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        Navigator.pushNamed(
          context,
          addAsset,
          arguments: AddAssetArguments(Asset(assetCode: assetCode)),
        ).then((asset) {
          if (asset != null) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final initValue = !_isAdmin ? _user?.email : null;
                return BookingRequest(initValue: initValue);
              },
            ).then((res) {
              _bloc
                  .onReq(ReqBooking(
                name: res.member,
                assetRef: !kReleaseMode
                    ? 'assets-dev/${(asset as Asset).id}'
                    : 'assets/${(asset as Asset).id}',
                note: res.note
              ))
                  .catchError((err) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(err)));
              });
            });
          }
        });
      }
    });
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
                } else if (state is AssetFailure) {
                  return Text(state.error);
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
                      _bloc
                          .onTransferTo(TransferTo(
                        booking.id,
                        booking.assetRef,
                        booking.employee,
                        DateTime.now(),
                      ))
                          .then((value) {
                        Navigator.pop(context);
                      }).catchError((err) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(err)));
                      });
                    },
                    child: const Text('Next day'),
                  )
                : Container(),
            TextButton(
              child: Text(booking.endedAt == null ? 'Trả' : 'Huỷ Trả'),
              onPressed: () {
                _bloc
                    .onReturn(ReturnBooking(
                  booking.id,
                  endedAt: booking.endedAt == null ? DateTime.now() : null,
                ))
                    .then((v) {
                  Navigator.pop(context);
                }).catchError((err) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(err)));
                });
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
