import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:iconly/iconly.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:walppeper/HomePage.dart';
import 'package:walppeper/colors.dart';
import 'package:walppeper/pages_loadinig.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // flutter_downloader requires extra iOS native setup (FlutterDownloaderPlugin
  // registrant callback). Downloads in this app target Android paths anyway.
  if (Platform.isAndroid) {
    await FlutterDownloader.initialize(
      debug: true,
      ignoreSsl: true,
    );
    FlutterDownloader.registerCallback(callbackDownloader);
    await requestStoragePermission();
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0; // Initially selected index
  List<FlashyTabBarItem> tabItems = [
    FlashyTabBarItem(
      inactiveColor: const Color.fromARGB(255, 4, 122, 181), // Set the icon color to white
      activeColor: const Color.fromARGB(255, 5, 145, 187),
      icon: const Icon(
        IconlyBold.home,
        size: 30.0,
      ),
      title: const Text('Home'),
    ),
    FlashyTabBarItem(
      inactiveColor: const Color.fromARGB(255, 10, 198, 219), // Set the icon color to white
      activeColor: Colors.white,
      icon: const Icon(
        IconlyBold.category,
        size: 30.0,
      ),
      title: const Text('Category'),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpaper Engine',
      theme: ThemeData(
        scaffoldBackgroundColor: BackgroundColor,
        fontFamily: fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const PageLoading(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}



void callbackDownloader(String id, int status, int progress) {
  print(
    'Callback on background isolate: '
    'task ($id) is in status ($status) and process ($progress)',
  );

  IsolateNameServer.lookupPortByName('downloader_send_port')
      ?.send([id, status, progress]);
}

Future<void> requestStoragePermission() async {
  final PermissionStatus status = await Permission.storage.request();
  if (status.isGranted) {
    // Permission granted, you can perform storage-related operations
  } else if (status.isDenied) {
    // Permission denied
  } else if (status.isPermanentlyDenied) {
    // Permission permanently denied, open app settings
    openAppSettings();
  }
}
