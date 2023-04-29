import 'package:flutter/material.dart';
import 'package:assets_management/screens/assets/asset_screen.dart';
import 'package:assets_management/screens/booking/my_booking.dart';

import '../screens/assets/add_asset.dart';
import '../screens/assets/asset_detail.dart';
import '../screens/profile/profile_screen.dart';

const String home = '/';
const String myAssets = '/assets';
const String addAsset = '/add-asset';
const String myAssetDetail = '/assets-detail';
const String myBooking = '/booking';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case myAssets:
        return MaterialPageRoute(builder: (_) => AssetScreen());
      case myAssetDetail:
        {
          final args = settings.arguments as AssetDetailArguments;
          return MaterialPageRoute(builder: (_) => AssetDetailScreen(args));
        }
      case addAsset:
        {
          final args = settings.arguments as AddAssetArguments;
          return MaterialPageRoute(builder: (_) => AddAssetScreen(args));
        }
      case myBooking:
        return MaterialPageRoute(builder: (_) => const MyBooking());
      default:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
    }
  }
}
