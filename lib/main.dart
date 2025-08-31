// File: lib/main.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'ads/ads_controller.dart';
import 'app_lifecycle/app_lifecycle.dart';
import 'audio/audio_controller.dart';
import 'crashlytics/crashlytics.dart';
import 'games_services/games_services.dart';
import 'in_app_purchase/in_app_purchase.dart';
import 'player_progress/player_progress.dart';
import 'settings/settings.dart';
import 'style/palette.dart';
import 'bubble_pop_router.dart'; // Import the router

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await guardWithCrashlytics(
    guardedMain,
  );
}

/// Without logging and crash reporting, this would be `void main()`.
void guardedMain() {
  if (kIsWeb || Platform.isIOS || Platform.isAndroid) {
    // Initialize mobile ads on supported platforms
    MobileAds.instance.initialize();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => SettingsController()),
          ChangeNotifierProvider(
            create: (context) => PlayerProgress()..initialize(),
          ),
          ProxyProvider2<SettingsController, ValueNotifier<AppLifecycleState>,
              AudioController>(
            create: (context) => AudioController()..initialize(),
            update: (context, settings, lifecycleNotifier, audio) {
              if (audio == null) throw ArgumentError.notNull('audio');
              audio.attachSettings(settings);
              audio.attachLifecycleNotifier(lifecycleNotifier);
              return audio;
            },
            dispose: (context, audio) => audio.dispose(),
          ),
          Provider(create: (context) => GamesServicesController()),
          Provider(create: (context) => InAppPurchaseController()),
          ProxyProvider<AppLifecycleStateNotifier, AdsController>(
            create: (_) => AdsController(MobileAds.instance),
            update: (_, lifecycleNotifier, ads) {
              ads!.attachLifecycleNotifier(lifecycleNotifier);
              return ads;
            },
            dispose: (_, ads) => ads.dispose(),
          ),
          ChangeNotifierProvider(create: (context) => Palette()),
        ],
        child: Builder(builder: (context) {
          final palette = context.watch<Palette>();

          return MaterialApp.router(
            title: 'Bubble Pop',
            theme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(
                seedColor: palette.darkPen,
                brightness: Brightness.light,
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(
                  fontFamily: 'Permanent Marker',
                ),
              ),
            ),
            routeInformationProvider: router.routeInformationProvider,
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
          );
        }),
      ),
    );
  }
}