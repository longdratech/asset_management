import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../models/asset.dart';

class AssetItem extends StatelessWidget {
  final Asset asset;

  const AssetItem({Key? key, required this.asset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final picSize = asset.pictures?.length ?? 0;

    return ListBody(
      children: [
        picSize > 0
            ? CarouselSlider.builder(
                itemCount: picSize,
                itemBuilder: (context, itemIndex, pageViewIndex) {
                  return Image(
                    image: NetworkImage(asset.pictures![itemIndex]),
                  );
                },
                options: CarouselOptions(
                  autoPlay: false,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  aspectRatio: 2.0,
                  initialPage: picSize,
                ),
              )
            : const Text(
                'No Picture!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        Text('Asset code: ${asset.assetCode}'),
        Text('Model name: ${asset.modelName}'),
        Text('Serial number: ${asset.serialNumber}'),
        Text('Loại: ${asset.type}'),
      ],
    );
  }
}
