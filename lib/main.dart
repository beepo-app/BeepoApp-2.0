import 'package:Beepo/app.dart';
import 'package:Beepo/firebase_options.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/providers/chat_provider.dart';
import 'package:Beepo/providers/new_point_working.dart';
import 'package:Beepo/providers/referral_provider.dart';
import 'package:Beepo/providers/time_base_provider.dart';
import 'package:Beepo/providers/total_points_provider.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/providers/withdraw_points_provider.dart';
import 'package:Beepo/services/notification_service.dart';
import 'package:Beepo/utils/encrypted_seed.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'session/foreground_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initializeNotification();

  await Hive.initFlutter();
  Hive.registerAdapter(EncryptSeedAdapter());

  // Attempt to handle large data more efficiently
  try {
    await Hive.openBox('beepo2.0');
  } catch (e) {
    debugPrint('Failed to open Hive box: $e');
    // Consider clearing or migrating data if necessary
  }

  await dotenv.load(fileName: ".env");

  await session.loadSaved();
  _monitorTotalUnreadBadge();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(
          create: (context) => TotalPointProvider(
            pointsProvider: context.read<NewPointsProvider>(),
            referralProvider: context.read<ReferralProvider>(),
            timeBasedPointsProvider: context.read<TimeBasedPointsProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WithDrawPointsProvider(
            pointsProvider: context.read<NewPointsProvider>(),
            referralProvider: context.read<ReferralProvider>(),
            timeBasedPointsProvider: context.read<TimeBasedPointsProvider>(),
            totalPointProvider: context.read<TotalPointProvider>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => NewPointsProvider()),
        ChangeNotifierProvider(create: (_) => ReferralProvider()),
        ChangeNotifierProvider(create: (_) => TimeBasedPointsProvider()),
      ],
      builder: (context, _) {
        return const GetMaterialApp(
          debugShowCheckedModeBanner: false,
          home: MyApp(),
        );
      },
    ),
  );
}

void _monitorTotalUnreadBadge() {
  if (!session.initialized) {
    return;
  }
  session.watchTotalNewMessageCount().listen((count) {
    if (count > 0) {
      FlutterAppBadger.updateBadgeCount(count);
    } else {
      FlutterAppBadger.removeBadge();
    }
  });
}
