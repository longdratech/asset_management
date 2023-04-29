import 'package:assets_management/blocs/asset/asset_bloc.dart';
import 'package:assets_management/blocs/asset/asset_event.dart';
import 'package:flutter/material.dart';

class AddAssetArguments {
  final String assetCode;

  AddAssetArguments(this.assetCode);
}

class AddAssetScreen extends StatelessWidget {
  final AddAssetArguments args;

  AddAssetScreen(this.args, {super.key});

  final _formKey = GlobalKey<FormState>();
  final _modelNameController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _typeController = TextEditingController();

  final _bloc = AssetBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
                enabled: false,
                initialValue: args.assetCode,
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
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    // if (_formKey.currentState!.validate()) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(content: Text('Processing Data')),
                    //   );
                    // }
                    // print(_formKey.currentState.save());
                    String modelName = _modelNameController.text;
                    String serialNumber = _serialNumberController.text;
                    String type = _typeController.text;
                    _bloc.add(
                      AddAsset(
                        assetCode: args.assetCode,
                        modelName: modelName,
                        serialNumber: serialNumber,
                        type: type,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Center(child: const Text('Thêm')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
