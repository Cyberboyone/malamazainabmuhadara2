import 'package:flutter/foundation.dart';

class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  static const String bannerAdUnitId = 'ca-app-pub-9529770421530115/9868251691';

  Future<void> init() async {
    debugPrint('AdsService: stub init (no plugin)');
  }
}
