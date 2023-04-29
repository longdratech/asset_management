import 'package:flutter/material.dart';

class AssetDetailArguments {
  final String assetCode;

  AssetDetailArguments(this.assetCode);
}

class AssetDetailScreen extends StatelessWidget {
  final AssetDetailArguments args;

  const AssetDetailScreen(this.args, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          args.assetCode,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Text("Asset already exists. Asset detail is developing"),
      ),
    );
  }
}
