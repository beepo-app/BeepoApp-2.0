import 'package:Beepo/providers/new_point_working.dart';
import 'package:Beepo/providers/referral_provider.dart';
import 'package:Beepo/providers/time_base_provider.dart';
import 'package:Beepo/providers/total_points_provider.dart';
import 'package:Beepo/services/database.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WithDrawPointsProvider extends ChangeNotifier {
  bool isLoading = false;
  int points = 0;
  final NewPointsProvider pointsProvider;
  final ReferralProvider referralProvider;
  final TimeBasedPointsProvider timeBasedPointsProvider;
  final TotalPointProvider totalPointProvider;

  WithDrawPointsProvider({
    required this.pointsProvider,
    required this.referralProvider,
    required this.timeBasedPointsProvider,
    required this.totalPointProvider,
  }) {
    loadFromHive();
  }

  Future<void> loadFromHive() async {
    points = await Hive.box('Beepo2.0').get('points', defaultValue: 0);
    notifyListeners();
  }

  Future<void> _saveToHive() async {
    await Hive.box('Beepo2.0').put('points', points);
  }

  Future<void> withdrawPoints(String ethAddress) async {
    isLoading = true;
    notifyListeners();

    try {
      var result = await dbWithdrawPoints(ethAddress);
      if (result != null && result['error'] == null) {
        // Reset points in all providers
        points = 0;
        pointsProvider.resetPoints();
        referralProvider.resetPoints();
        timeBasedPointsProvider.resetPoints();
        totalPointProvider.resetPoints();

        await _saveToHive();
      }
    } catch (e) {
      beepoPrint(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
