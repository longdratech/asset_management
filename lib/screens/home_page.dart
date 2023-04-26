import 'package:assets_management/screens/scanner_page.dart';
import 'package:flutter/material.dart';
import 'generator_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Welcome to Canon Assets Management",
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                "You can Generate or Scan QR Code to...",
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const Image(
                image: NetworkImage(
                    'https://media.istockphoto.com/vectors/qr-code-scan-phone-icon-in-comic-style-scanner-in-smartphone-vector-vector-id1166145556'),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Button(
                'Scan QR Code',
                const ScanPage(),
              ),
              const SizedBox(
                height: 6.0,
              ),
              Button(
                'Generate QR Code',
                const GenerateQrCodePage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget Button(String text, Widget widget) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      height: 50.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Colors.black,
              width: 1.0,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(
              32.0,
            ),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => widget),
          );
        },
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
