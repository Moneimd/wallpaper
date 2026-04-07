import 'package:multi_ads/multi_ads.dart';

late Future<String> emotes;

var configeApp;

/// Filled in [PageLoading] after remote JSON loads; null until then.
MultiAds? g_ads;

// https://drive.google.com/file/d//view?usp=share_link
const String pathJson =
    "https://drive.google.com/uc?export=download&id=1jZ_cQ4uKp-VUtfiX1QjgVcsGs2C1y4eX";

Future<bool> onWillpop() async {
  Future.delayed(const Duration(seconds: 2), () {
    g_ads?.interInstance.showInterstitialAd();
  });
  return true;
}
