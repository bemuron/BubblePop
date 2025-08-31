// File: lib/src/ads/ads_controller.dart
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app_lifecycle/app_lifecycle.dart';

/// Allows awarding ads to be shown, and handles loading and errors.
class AdsController {
  final MobileAds _mobileAds;
  AppLifecycleStateNotifier? _lifecycleNotifier;

  AdsController(this._mobileAds);

  /// Preloaded ad that can be used to show a rewarded ad to the player.
  RewardedAd? _rewardedAd;

  /// Preloaded interstitial ad
  InterstitialAd? _interstitialAd;

  AppLifecycleObserver? _lifecycleObserver;

  /*void attachLifecycleObserver(AppLifecycleObserver lifecycleObserver) {
    _lifecycleObserver = lifecycleObserver;
  }*/

  void attachLifecycleNotifier(AppLifecycleStateNotifier notifier) {
    _lifecycleNotifier = notifier;

    // Listen to lifecycle changes
    _lifecycleNotifier!.addListener(_handleLifecycleChange);
  }

  void _handleLifecycleChange() {
    final state = _lifecycleNotifier!.value;

    switch (state) {
      case AppLifecycleState.paused:
      // Pause ad-related operations if needed
        print('App paused: consider pausing ad loading or tracking');
        break;
      case AppLifecycleState.resumed:
      // Resume ad-related operations
        print('App resumed: resume ad loading or tracking');
        break;
      case AppLifecycleState.inactive:
        print('App inactive');
        break;
      case AppLifecycleState.detached:
        print('App detached');
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        print('App hidden');
        break;
    }
  }

  /*void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }*/

  void dispose() {
    _lifecycleNotifier?.removeListener(_handleLifecycleChange);
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }

  /// Preload a rewarded ad to be used later.
  void preloadAd() {
    _preloadRewardedAd();
    _preloadInterstitialAd();
  }

  /// Show a rewarded ad, if available.
  void showRewardedAd({
    required VoidCallback onUserEarnedReward,
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
    _rewardedAd = null;
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
  }

  void _preloadRewardedAd() {
    // Use test ad unit IDs
    final adUnitId = _getRewardedAdUnitId();

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
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
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('InterstitialAd failed to load: $error');
          }
        },
      ),
    );
  }

  /// Returns the ad unit ID for rewarded ads.
  ///
  /// Throws an [UnsupportedError] when called on unsupported platforms.
  String _getRewardedAdUnitId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Returns the ad unit ID for interstitial ads.
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