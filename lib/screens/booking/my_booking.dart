import 'package:assets_management/blocs/booking/booking_event.dart';
import 'package:assets_management/blocs/booking/booking_state.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  final FirestoreRepository repository = FirestoreRepository();

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
        create: (ctx) => BookingBloc()..add(const LoadBooking()),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: PreferredSize(
              preferredSize: Size.fromHeight(30),
              child: TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                onTap: (i) => _tabSelect,
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
          body: BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              if (state is BookingInitial) {
                return Text('Loading...');
              } else if (state is BookingLoaded) {
                final data = state.booking;
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int i) {
                      return TextButton(
                        onPressed: () => _showMyDialog(data[i].id),
                        child: ListBody(
                          children: <Widget>[
                            Text('Asset code:'),
                            Text("Thời gian mượn: ${data[i].createdAt}"),
                            Text("Người mượn:  ${data[i].employee}"),
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Text('Fail');
              }
            },
          ),
        ),
      ),
    );
  }

  _tabSelect(int index) {
    _selectedIndex = index;
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
}
