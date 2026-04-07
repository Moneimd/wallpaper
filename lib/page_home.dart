import 'package:flutter/material.dart';
import 'package:multi_ads/multi_ads.dart';
import 'package:walppeper/const.dart';

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test App")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {
                    g_ads?.interInstance.showInterstitialAd();
                  },
                  child: const Text("Show inter")),
              ElevatedButton(
                  onPressed: () {
                    g_ads?.rewardInstance.showRewardAd(() {
                      print("---------------------------------------------");
                    });
                  },
                  child: const Text("show reward")),
            ],
          ),
          g_ads?.nativeInstance.getNativeAdWidget() ?? const SizedBox(),
          const SizedBox(height: 20),
          Container(
            color: Colors.red,
            child: g_ads == null
                ? const SizedBox()
                : CustomBanner(key: UniqueKey(), ads: g_ads!.bannerInstance),
          ),
          const SizedBox(height: 1),
        ],
      ),
    );
  }
}
