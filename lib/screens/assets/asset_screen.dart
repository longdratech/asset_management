import 'package:assets_management/blocs/asset/asset_bloc.dart';
import 'package:assets_management/blocs/asset/asset_event.dart';
import 'package:assets_management/blocs/asset/asset_state.dart';
import 'package:assets_management/constants/routes.dart';
import 'package:assets_management/models/asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_asset.dart';
import 'asset_detail.dart';

class AssetScreen extends StatefulWidget {
  const AssetScreen({super.key});

  @override
  State<AssetScreen> createState() => _AssetScreenState();
}

class _AssetScreenState extends State<AssetScreen> {
  final bloc = AssetBloc();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

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
            builder: (ctx, state) {
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
                            trailing: Text(asset.type ?? "N/A"),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                addAsset,
                                arguments: AddAssetArguments(
                                  Asset(
                                    id: asset.id,
                                    modelName: asset.modelName,
                                    serialNumber: asset.serialNumber,
                                    assetCode: asset.assetCode,
                                    type: asset.type,
                                  ),
                                ),
                              );
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              heroTag: "text",
              onPressed: () async {
                final controller = TextEditingController();
                await showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: const Text('Nhập mã tài sản'),
                      content: TextField(
                        controller: controller,
                      ),
                      actions: <Widget>[
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          child: const Text('Xác nhận'),
                          onPressed: () async {
                            final assetCode = controller.text;
                            if (assetCode.isNotEmpty) {
                              _process(context, controller.text);
                            }
                            controller.clear();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.text_fields),
            ),
          ),
          FloatingActionButton(
            onPressed: () async {
              String assetCode = await FlutterBarcodeScanner.scanBarcode(
                '#ff6666',
                'Cancel',
                true,
                ScanMode.QR,
              );

              if (assetCode != "-1") {
                _process(context, assetCode);
              }
            },
            child: const Icon(Icons.camera_alt_outlined),
          ),
        ],
      ),
    );
  }

  _process(BuildContext context, String assetCode) {
    bloc.getAssets(LoadAsset(assetCode: assetCode)).then((asset) {
      if (asset == null) {
        Navigator.of(context).pushNamed(
          addAsset,
          arguments: AddAssetArguments(Asset(assetCode: assetCode)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tài sản đã tồn tại!')),
        );
      }
    });
  }
}
