import 'package:assets_management/blocs/asset/asset_bloc.dart';
import 'package:assets_management/blocs/asset/asset_event.dart';
import 'package:assets_management/blocs/asset/asset_state.dart';
import 'package:assets_management/constants/routes.dart';
import 'package:assets_management/models/asset.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
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
              } else if (state is AssetFailure) {
                return Center(child: Text(state.error));
              } else if (state is AssetLoaded) {
                final assets = state.assets;
                return assets.isNotEmpty
                    ? ListView(
                        children: assets.map<Widget>((asset) {
                          return Dismissible(
                            key: Key(asset.id ?? asset.assetCode),
                            background: Container(color: Colors.red),
                            confirmDismiss: (v) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Xác nhận xóa tài sản"),
                                    content: Text(
                                      "Bạn có chắc chắn muốn xóa tải sản ${asset.modelName} (${asset.assetCode}) ra khỏi danh sách này chứ?",
                                    ),
                                    actions: <Widget>[
                                      OutlinedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text("Hủy bỏ"),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          bloc
                                              .onRemoveOne(asset.id!)
                                              .then((value) {
                                            Navigator.of(context).pop();
                                          }).catchError((err) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(err)));
                                          });
                                        },
                                        child: const Text("Xác nhận"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) {
                              setState(() {
                                assets.remove(asset);
                              });

                              // Then show a snackbar.
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$asset dismissed')));
                            },
                            child: ListTile(
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
                            ),
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
