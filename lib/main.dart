import 'package:assets_management/screens/assets/asset_screen.dart';
import 'package:assets_management/screens/booking/my_booking.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'constants/routes.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];

    return MaterialApp(
      title: 'AppLocalizations.of(context).helloWorld',
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? signIn : home,
      onGenerateRoute: Routes.generateRoute,
      routes: {
        '/sign-in': (context) {
          return SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, home);
              }),
            ],
          );
        },
        '/profile': (context) {
          return ProfileScreen(
            providers: providers,
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(context, '/sign-in');
              }),
            ],
          );

        },
      },
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  List<NavigationDestination> _destinations(BuildContext context) {
    return const [
      NavigationDestination(
        icon: Icon(Icons.manage_history),
        label: 'Booking',
      ),
      NavigationDestination(
        icon: Icon(Icons.web_asset),
        label: 'Canon\'s assets',
      ),
      NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  static final List<Widget> _screens = <Widget>[
    const MyBooking(),
    const AssetScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _screens.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        destinations: _destinations(context),
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
