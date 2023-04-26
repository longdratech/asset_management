import 'package:flutter/material.dart';

class AssetDetailArguments {
  final String id;

  AssetDetailArguments(this.id);
}

class AssetDetailScreen extends StatefulWidget {
  // final String? id;

  const AssetDetailScreen({Key? key}) : super(key: key);

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
