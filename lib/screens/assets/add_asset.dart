import 'package:assets_management/blocs/asset/asset_bloc.dart';
import 'package:assets_management/blocs/asset/asset_event.dart';
import 'package:assets_management/models/asset.dart';
import 'package:flutter/material.dart';

class AddAssetArguments {
  final Asset asset;

  AddAssetArguments(this.asset);
}

class AddAssetScreen extends StatefulWidget {
  final AddAssetArguments args;

  AddAssetScreen(this.args, {super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _assetCodeController;
  late TextEditingController _modelNameController;
  late TextEditingController _serialNumberController;
  late TextEditingController _typeController;

  final _bloc = AssetBloc();

  @override
  void initState() {
    _assetCodeController = TextEditingController(text: widget.args.asset.assetCode);
    _modelNameController = TextEditingController(text: widget.args.asset.modelName);
    _serialNumberController = TextEditingController(text: widget.args.asset.serialNumber);
    _typeController = TextEditingController(text: widget.args.asset.type);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm tài sản mới',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _assetCodeController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Mã sản phẩm',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _modelNameController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Tên sản phẩm',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _serialNumberController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Số seri',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Loại device',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: ElevatedButton(
                  onPressed: () async {
                    final assetCode = _assetCodeController.text;
                    final modelName = _modelNameController.text;
                    final serialNumber = _serialNumberController.text;
                    final type = _typeController.text;

                    if(widget.args.asset.id != null) {
                      await _bloc.onUpdate(
                        Asset(
                          id: widget.args.asset.id,
                          assetCode: assetCode,
                          modelName: modelName,
                          serialNumber: serialNumber,
                          type: type,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      final asset = await _bloc.onAdd(
                        AddAsset(
                          assetCode: widget.args.asset.assetCode,
                          modelName: modelName,
                          serialNumber: serialNumber,
                          type: type,
                        ),
                      );
                      Navigator.pop(context, asset);
                    }
                  },
                  child: const Center(child: Text('Thêm')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
