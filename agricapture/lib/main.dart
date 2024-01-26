import 'package:agricapture/screens/farmer_form_screen.dart';
import 'package:agricapture/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

var kColorScheme =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 167, 246));

var kDarkColorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 0, 152, 199));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'AgriCapture',
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData.dark().copyWith(
          useMaterial3: true,
          colorScheme: kDarkColorScheme,
          cardTheme: const CardTheme().copyWith(
              color: kDarkColorScheme.secondaryContainer,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kDarkColorScheme.primaryContainer,
              foregroundColor: kDarkColorScheme.onPrimaryContainer,
            ),
          ),
        ),
        theme: ThemeData().copyWith(
          useMaterial3: true,
          colorScheme: kColorScheme,
          appBarTheme: const AppBarTheme().copyWith(
              backgroundColor: kColorScheme.onPrimaryContainer,
              foregroundColor: kColorScheme.primaryContainer),
          cardTheme: const CardTheme().copyWith(
              color: kColorScheme.secondaryContainer,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: kColorScheme.primaryContainer),
          ),
        ),
        home: Scaffold(body: PermissionHandlerScreen()));
  }
}

class PermissionHandlerScreen extends StatefulWidget {
  @override
  _PermissionHandlerScreenState createState() =>
      _PermissionHandlerScreenState();
}

class _PermissionHandlerScreenState extends State<PermissionHandlerScreen> {
  @override
  void initState() {
    super.initState();
    permissionServiceCall();
  }

  permissionServiceCall() async {
    await permissionServices().then(
      (value) {
        if (value != null) {
          if (value[Permission.storage]!.isGranted &&
              value[Permission.camera]!.isGranted &&
              value[Permission.locationWhenInUse]!.isGranted &&
              value[Permission.microphone]!.isGranted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SplashScreen()),
            );
          }
        }
      },
    );
  }

  /*Permission services*/
  Future<Map<Permission, PermissionStatus>> permissionServices() async {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
      Permission.locationWhenInUse,
      Permission.microphone,
      //add more permission to request here.
    ].request();

    if (statuses[Permission.storage]!.isPermanentlyDenied) {
      await openAppSettings().then(
        (value) async {
          if (value) {
            if (await Permission.storage.status.isPermanentlyDenied == true &&
                await Permission.storage.status.isGranted == false) {
              openAppSettings();
              // permissionServiceCall();
            }
          }
        },
      );
    } else {
      if (statuses[Permission.storage]!.isDenied) {
        permissionServiceCall();
      }
    }
    if (statuses[Permission.microphone]!.isPermanentlyDenied) {
      await openAppSettings().then(
        (value) async {
          if (value) {
            if (await Permission.microphone.status.isPermanentlyDenied ==
                    true &&
                await Permission.microphone.status.isGranted == false) {
              openAppSettings();
              // permissionServiceCall();
            }
          }
        },
      );
    } else {
      if (statuses[Permission.microphone]!.isDenied) {
        permissionServiceCall();
      }
    }
    if (statuses[Permission.locationWhenInUse]!.isPermanentlyDenied) {
      await openAppSettings().then(
        (value) async {
          if (value) {
            if (await Permission.locationWhenInUse.status.isPermanentlyDenied ==
                    true &&
                await Permission.locationWhenInUse.status.isGranted == false) {
              openAppSettings();
              // permissionServiceCall();
            }
          }
        },
      );
    } else {
      if (statuses[Permission.locationWhenInUse]!.isDenied) {
        permissionServiceCall();
      }
    }
    if (statuses[Permission.camera]!.isPermanentlyDenied) {
      await openAppSettings().then(
        (value) async {
          if (value) {
            if (await Permission.camera.status.isPermanentlyDenied == true &&
                await Permission.camera.status.isGranted == false) {
              openAppSettings();
              // permissionServiceCall();
            }
          }
        },
      );
      //openAppSettings();
      //setState(() {});
    } else {
      if (statuses[Permission.camera]!.isDenied) {
        permissionServiceCall();
      }
    }

    return statuses;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    permissionServiceCall();
    return Scaffold(
        body: Container(
      child: Center(
        child: InkWell(
          onTap: () {
            permissionServiceCall();
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/logo.png', width: screenSize.width / 1.5),
                const SizedBox(height: 20),
                Text('Agri Capture',
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                const Text('Loading...'),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
