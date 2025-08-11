import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  BannerAd? bannerAd;
  bool _isInterstitialLoaded = false;

  final String interstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // Test
  final String bannerUnitId = 'ca-app-pub-3940256099942544/9214589741'; // Test

  void loadInterstitialAd() {
    _interstitialAd?.dispose();
    InterstitialAd.load(
      adUnitId: AdUnitIds.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          _interstitialAd?.setImmersiveMode(true);
          print("Interstitial Loaded");
        },
        onAdFailedToLoad: (error) {
          print("Failed to load interstitial: $error");
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  void showInterstitialAd({Function? onAdDismissed}) {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialLoaded = false;
          loadInterstitialAd(); // preload for next time
          if (onAdDismissed != null) onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isInterstitialLoaded = false;
          loadInterstitialAd();
          if (onAdDismissed != null) onAdDismissed();
        },
      );
      _interstitialAd!.show();
    } else {
      print("Interstitial not ready");
      if (onAdDismissed != null) onAdDismissed();
    }
  }
}
