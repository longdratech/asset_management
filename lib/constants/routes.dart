import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:assets_management/screens/assets/asset_screen.dart';
import 'package:assets_management/screens/booking/my_booking.dart';

import '../screens/assets/add_asset.dart';
import '../screens/assets/asset_detail.dart';

const String signIn = '/sign-in';
const String home = '/';
const String profile = '/profile';
const String myAssets = '/assets';
const String addAsset = '/add-asset';
const String myAssetDetail = '/assets-detail';
const String myBooking = '/booking';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final providers = [EmailAuthProvider()];

    switch (settings.name) {
      case signIn:
        return MaterialPageRoute(
          builder: (_) => SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, home);
              }),
            ],
          ),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const MyBooking());
      case profile:
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(
            providers: providers,
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(context, signIn);
              }),
            ],
          ),
        );
      case myAssets:
        return MaterialPageRoute(builder: (_) => const AssetScreen());
      case myAssetDetail:
        final args = settings.arguments as AssetDetailArguments;
        return MaterialPageRoute(builder: (_) => AssetDetailScreen(args));
      case addAsset:
        final args = settings.arguments as AddAssetArguments;
        return MaterialPageRoute(builder: (_) => AddAssetScreen(args));
      case myBooking:
        return MaterialPageRoute(builder: (_) => const MyBooking());
      default:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
    }
  }
}
