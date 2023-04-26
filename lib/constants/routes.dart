import 'package:flutter/material.dart';
import 'package:assets_management/screens/assets/asset_screen.dart';
import 'package:assets_management/screens/booking/my_booking.dart';

import '../screens/assets/asset_detail.dart';
import '../screens/home_page.dart';

const String home = '/';
const String myAssets = '/assets';
const String myAssetDetail = '/assets-detail';
const String myBooking = '/booking';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case myAssets:
        return MaterialPageRoute(builder: (_) => const AssetScreen());
      case myAssetDetail: {
        final args = settings.arguments as AssetDetailArguments;
        return MaterialPageRoute(builder: (_) => const AssetDetailScreen());
      }
      case myBooking:
        return MaterialPageRoute(builder: (_) => const MyBooking());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
