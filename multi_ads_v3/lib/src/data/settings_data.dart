import 'package:multi_ads/src/utils/log.dart';

class Settings {
  final List<String> banners;
  final List<String> inters;
  final List<String> nativees;
  final List<String> rewards;

  Settings.fromJson(Map<String, dynamic> json)
      : banners = _toList(json['banners']),
        inters = _toList(json['inters']),
        nativees = _toList(json['nativees']),
        rewards = _toList(json['rewards']) {
    Log.log("banners: ------------------ $banners");
    Log.log("inters: ------------------ $inters");
    Log.log("nativees: ------------------ $nativees");
    Log.log("rewards: ------------------ $rewards");
  }

  // helper function to convert dynamic to List<String> safely
  static List<String> _toList(dynamic value) {
    if (value == null) return [];
    if (value is String) return value.isEmpty ? [] : value.split(",");
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
