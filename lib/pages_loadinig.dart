import 'dart:convert';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:multi_ads/multi_ads.dart';
import 'package:walppeper/HomePage.dart';
import 'package:walppeper/const.dart';
class PageLoading extends StatefulWidget {
  const PageLoading({Key? key}) : super(key: key);

  @override
  State<PageLoading> createState() => _PageLoadingState();
}

class _PageLoadingState extends State<PageLoading> {
  static bool get _canUseMobileAds =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Lets the platform channel register (iOS implicit engine / first frame).
  Future<void> _waitForPluginBinding() async {
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  void initState() {
    super.initState();
    fetchAdsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                SizedBox(
                  height: 150,
                  //child: Image.asset("assets/playstore.png"),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (isLoading)
                    ? const SpinKitWanderingCubes(
                        color: Colors.white,
                        size: 40.0,
                      )
                    : ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red)),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          fetchAdsData();
                        },
                        child: const Text(
                          "Try again",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  bool isLoading = true;
  Future<void> fetchAdsData() async {
    try {
      initOneSignall();
      var url = Uri.parse(pathJson);
      var response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        var data2 = json.decode(response.body);
        g_ads = MultiAds(response.body);
        if (_canUseMobileAds) {
          await _waitForPluginBinding();
          if (!mounted) return;
          try {
            await g_ads!.init();
            await g_ads!.loadAds();
          } on MissingPluginException catch (e) {
            debugPrint(
              'google_mobile_ads not linked — stop the app, run '
              '`flutter clean && flutter pub get` then rebuild (iOS: '
              '`cd ios && pod install`). $e',
            );
          }
        }
        if (!mounted) return;
        setState(() {
          configeApp = data2["config"];
        });
        await Future.delayed(const Duration(seconds: 2));
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        print(response.statusCode);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  initOneSignall() async {
    //   if (kDebugMode) {
    //     OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    //   }
    //   await OneSignal.shared.setAppId(oneSignale);
    //   OneSignal.shared
    //       .setNotificationOpenedHandler((OSNotificationOpenedResult result) {});
    //   OneSignal.shared
    //       .promptUserForPushNotificationPermission()
    //       .then((accepted) {});
  }
}
