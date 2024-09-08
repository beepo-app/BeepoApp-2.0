import 'package:Beepo/services/database.dart'; // Assuming dbFetchReferrals and dbUpdateReferrals are defined here
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ReferralProvider with ChangeNotifier {
  int _referrals = 0;
  int _points = 0;

  int get referrals => _referrals;
  int get points => _points;

  void resetPoints() {
    _points = 0;
    savePointsToHive();
    notifyListeners();
  }

  Future<void> savePointsToHive() async {
    var box = await Hive.openBox('Beepo2.0');
    await box.put('referralPoints', _points);
  }

  ReferralProvider() {
    fetchReferralsFromHive();
  }

  Future<void> fetchReferrals(String ethAddress) async {
    try {
      var data = await dbFetchReferrals(ethAddress);
      if (data != null) {
        _referrals = data['referrals'] ?? 0;
        _points = data['points'] ?? 0;

        // Save to Hive
        var box = await Hive.openBox('Beepo2.0');
        box.put('referrals', _referrals);
        box.put('points', _points);
      }
    } catch (e) {
      print("Error fetching referrals: $e");
      // Handle the error appropriately, e.g., set an error state
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchReferralsFromHive() async {
    var box = await Hive.openBox('Beepo2.0');
    _referrals = box.get('referrals', defaultValue: 0);
    _points = box.get('points', defaultValue: 0);
    notifyListeners();
  }

  Future<void> updateReferrals(String refId) async {
    var result = await dbUpdateReferrals(refId);
    if (result.containsKey('success')) {
      _referrals += 1;
      _points += 100; // Assuming each referral adds 100 points

      // Save to Hive
      var box = await Hive.openBox('Beepo2.0');
      box.put('referrals', _referrals);
      box.put('points', _points);

      notifyListeners();
    } else {
      print(result['error']);
    }
  }
}
