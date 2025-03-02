import 'dart:async';
import 'dart:convert';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/providers/chat_provider.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/screens/Auth/lock_screen.dart';
import 'package:Beepo/screens/Auth/onboarding_screen.dart';
import 'package:Beepo/services/notification_service.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xmtp/xmtp.dart' as xmtp;
import 'package:get/get.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final AppLifecycleListener _lifeCycleListener;
  late bool? isSignedUp;
  late bool isLocked;
  late final StreamSubscription _lockSubscription;
  late final StreamSubscription _messageSubscription;
  late final StreamSubscription _convosSubscription;
  List<xmtp.DecodedMessage>? data;

  @override
  void initState() {
    super.initState();

    // Initialize Hive data
    isSignedUp = Hive.box('Beepo2.0').get('isSignedUp');
    isLocked = Hive.box('Beepo2.0').get('isLocked') ?? false;

    _lifeCycleListener =
        AppLifecycleListener(onStateChange: _onLifeCycleChanged);
    _initializeApp();

    _lockSubscription =
        Hive.box('Beepo2.0').watch(key: "isLocked").listen((event) {
      setState(() {
        isLocked = event.value;
      });
    });

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    _messageSubscription =
        chatProvider.findAndWatchAllMessages().listen((event) {
      chatProvider.updateMessages(event);
    });

    _convosSubscription = chatProvider.findAndWatchAllConvos().listen((event) {
      chatProvider.updateConvos(event);
    });
  }

  @override
  void dispose() {
    _lockSubscription.cancel();
    _messageSubscription.cancel();
    _convosSubscription.cancel();
    _lifeCycleListener.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final acctProvider = Provider.of<AccountProvider>(context, listen: false);

      await Future.wait([
        acctProvider.initDB(),
        walletProvider.initPlatformState(),
        acctProvider.getAllUsers(),
      ]);

      chatProvider
          .findAndWatchAllStatuses(FirebaseFirestore.instance)
          .listen((event) {
        chatProvider.saveStatuses(acctProvider.db);
      });

      acctProvider
          .findAndWatchAllUsers(FirebaseFirestore.instance)
          .listen((event) async {
        await acctProvider.getAllUsers();
      });

      // Check if user data exists in Hive
      final ethAddress = Hive.box('Beepo2.0').get('ethAddress');
      final displayName = Hive.box('Beepo2.0').get('displayName');
      final imageUrl = Hive.box('Beepo2.0').get('imageUrl');

      if (ethAddress != null && displayName != null && imageUrl != null) {
        setState(() {
          isSignedUp = true; // User data exists, navigate to dashboard
        });
      } else {
        setState(() {
          isSignedUp =
              false; // User data does not exist, navigate to onboarding
        });
      }
    } catch (e) {
      if (kDebugMode) {
        beepoPrint(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 546),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Beepo',
          theme: ThemeData(
            useMaterial3: true,
          ),
          home: isSignedUp == null
              ? const OnboardingScreen()
              : isSignedUp!
                  ? const LockScreen()
                  : const OnboardingScreen(),
        );
      },
    );
  }

  void _onLifeCycleChanged(AppLifecycleState state) async {
    bool isAutoLockSwitch =
        Hive.box('Beepo2.0').get('isAutoLockSwitch') ?? false;
    if (isAutoLockSwitch) {
      switch (state) {
        case AppLifecycleState.resumed:
          beepoPrint('Back to app');
          break;
        case AppLifecycleState.paused:
          Hive.box('Beepo2.0').put('isLocked', true);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LockScreen()));
          beepoPrint('left app paused');
          break;
        case AppLifecycleState.detached:
          Hive.box('Beepo2.0').put('isLocked', true);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LockScreen()));
          beepoPrint('left app detached');
          break;
        case AppLifecycleState.inactive:
          beepoPrint('left app inactive');
          break;
        case AppLifecycleState.hidden:
          Hive.box('Beepo2.0').put('isLocked', true);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LockScreen(),
            ),
          );
          beepoPrint('left app hidden');
          break;
      }
    }
  }
}

void sendWalletNotification(Map data) async {
  try {
    await NotificationService.showNotifications(
      title: "You have received ",
      body: "You have received ",
      summary: '',
      payload: {'navigate': "true", "destination": "Wallet"},
    );
  } catch (e) {
    beepoPrint(e);
  }
}

void sendNotification(xmtp.DecodedMessage msg) async {
  List? users = Hive.box('Beepo2.0').get('allUsers', defaultValue: null);

  Map? d = users?.firstWhereOrNull(
      (element) => element['ethAddress'].toString() == msg.sender.toString());

  try {
    await NotificationService.showNotifications(
      title: d?['displayName'] ?? msg.sender.toString(),
      body: msg.content.toString(),
      summary: '',
      img: d?['image'],
      payload: {
        'navigate': "true",
        'topic': msg.topic,
        'userData': jsonEncode(d),
        'sender': msg.sender.toString()
      },
    );
  } catch (e) {
    beepoPrint(e);
  }
}
