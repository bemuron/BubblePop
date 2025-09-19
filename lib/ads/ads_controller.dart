// File: lib/src/ads/ads_controller.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Allows showing ads and handles loading and errors.
class AdsController extends ChangeNotifier {
  final MobileAds _mobileAds;

  AdsController(this._mobileAds);

  /// Preloaded ad that can be used to show a rewarded ad to the player.
  RewardedAd? _rewardedAd;

  // Track the loading status of the rewarded ad.
  bool _isRewardedAdLoaded = false;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  /// Preloaded interstitial ad
  InterstitialAd? _interstitialAd;

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  /// Preload a rewarded ad and an interstitial ad.
  void preloadAd() {
    _preloadRewardedAd();
    _preloadInterstitialAd();
  }

  /// Show a rewarded ad, if available.
  void showRewardedAd({
    required VoidCallback onUserEarnedReward,
    required VoidCallback onAdDismissed, // Add this new callback
  }) {
    if (_rewardedAd == null) {
      if (kDebugMode) {
        print('Tried to show rewarded ad before preloading.');
      }
      return;
    }

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      onUserEarnedReward();
    });

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        onAdDismissed(); // Call the resume callback here
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        onAdDismissed(); // Also call it if the ad fails to show
        ad.dispose();
      },
    );

    // Reset the state and start pre-loading the next ad.
    _rewardedAd = null;
    _isRewardedAdLoaded = false;
    preloadAd();
  }

  /// Show an interstitial ad, if available.
  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      if (kDebugMode) {
        print('Tried to show interstitial ad before preloading.');
      }
      return;
    }

    await _interstitialAd!.show();
    _interstitialAd = null;
    preloadAd();
  }

  void _preloadRewardedAd() {
    // Return if an ad is already loaded
    if (_isRewardedAdLoaded) return;

    // Use test ad unit IDs
    final adUnitId = _getRewardedAdUnitId();

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          // Notify listeners that the ad state has changed, so the UI can rebuild.
          notifyListeners();
          if (kDebugMode) {
            print('Rewarded ad loaded.');
          }
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          _rewardedAd?.dispose();
          if (kDebugMode) {
            print('RewardedAd failed to load: $error');
          }
        },
      ),
    );
  }

  void _preloadInterstitialAd() {
    final adUnitId = _getInterstitialAdUnitId();

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('InterstitialAd failed to load: $error');
          }
        },
      ),
    );
  }

  String _getRewardedAdUnitId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485360'; // Test ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  String _getInterstitialAdUnitId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}