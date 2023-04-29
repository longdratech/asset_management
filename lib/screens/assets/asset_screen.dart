import 'package:assets_management/blocs/asset/asset_bloc.dart';
import 'package:assets_management/blocs/asset/asset_event.dart';
import 'package:assets_management/blocs/asset/asset_state.dart';
import 'package:assets_management/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_asset.dart';
import 'asset_detail.dart';

class AssetScreen extends StatelessWidget {
  AssetScreen({super.key});

  final bloc = AssetBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Tài sản',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () {
          bloc.add(const LoadAsset());
          return Future<void>.delayed(const Duration(seconds: 1));
        },
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<AssetBloc, AssetState>(
            bloc: bloc..add(const LoadAsset()),
            builder: (context, state) {
              if (state is AssetLoading) {
                return const Center(child: Text('Loading...'));
              } else if (state is AssetLoaded) {
                final assets = state.assets;
                return assets.isNotEmpty
                    ? ListView(
                        children: assets.map<Widget>((asset) {
                          return ListTile(
                            title: Text(asset.assetCode),
                            subtitle: Text(asset.modelName ?? "N/A"),
                            trailing: Text(asset.type),
                            onTap: () {
                              // Navigator.pushNamed(context, myAssetDetail);
                            },
                          );
                        }).toList(),
                      )
                    : const Center(child: Text('No data!'));
              }
              return const Center(child: Text('Đã có lỗi xảy ra'));
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String assetCode = await FlutterBarcodeScanner.scanBarcode(
            '#ff6666',
            'Cancel',
            true,
            ScanMode.QR,
          );

          final asset = await bloc.getAsset(LoadAsset(assetCode: assetCode));
          final data = (await asset?.get())?.data();

          if (data == null) {
            Navigator.of(context)
                .pushNamed(addAsset, arguments: AddAssetArguments(assetCode));
          } else {
            Navigator.of(context).pushNamed(myAssetDetail,
                arguments: AssetDetailArguments(assetCode));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
