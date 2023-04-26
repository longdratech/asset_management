import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants/routes.dart';

class AssetScreen extends StatefulWidget {
  const AssetScreen({super.key});

  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  String qrCodeResult = "Not Yet Scanned";

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    CollectionReference assets = firestore.collection('assets');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'QR Code Scanner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: assets.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          return ListView(
            children: snapshot.data!.docs.map<Widget>((
                DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;
              return ListTile(
                title: Text(data['assetCode']),
                subtitle: Text(data['serialNumber']),
                onTap: () {
                  Navigator.pushNamed(context, myAssetDetail);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
