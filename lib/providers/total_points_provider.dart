import 'package:Beepo/providers/new_point_working.dart';
import 'package:Beepo/providers/referral_provider.dart';
import 'package:Beepo/providers/time_base_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class TotalPointProvider extends ChangeNotifier {

  int totalPoints = 0;
  final NewPointsProvider pointsProvider;
  final ReferralProvider referralProvider;
  final TimeBasedPointsProvider timeBasedPointsProvider;

  TotalPointProvider({
    required this.pointsProvider,
    required this.referralProvider,
    required this.timeBasedPointsProvider,
  }) {
    loadRankFromLocal();
  }
  
  MapEntry<String, IconData> rankEntry = const MapEntry('', Icons.error);

  void resetPoints() {
    totalPoints = 0;
    saveTotalPointsToHive();
    notifyListeners();
  }

  Future<void> saveTotalPointsToHive() async {
    var box = await Hive.openBox('BeepoRankData');
    await box.put('totalPoints', totalPoints);
  }

  Future<void> updateTotalPoints({
    required int dailyPoints,
    required int withdrawPoints,
    required int pointProviderPoints,
    required int activeTimePoints,
    required int referralPoints,
    required String ethAddress,
  }) async {
    totalPoints = dailyPoints +
        withdrawPoints +
        pointProviderPoints +
        activeTimePoints +
        referralPoints;
    rankEntry = setRank(totalPoints);

    // Save to database and local storage
    await saveRankToDatabase(ethAddress);
    await saveRankToLocal(totalPoints, rankEntry.key);

    notifyListeners();
  }

  MapEntry<String, IconData> setRank(int points) {
    if (points >= 0 && points <= 500) {
      return const MapEntry('Novice', Icons.sentiment_satisfied);
    }
    if (points >= 5000 && points < 10000) {
      return const MapEntry('Amateur', Icons.sentiment_neutral);
    }
    if (points >= 10000 && points < 18000) {
      return const MapEntry('Senior', Icons.sentiment_satisfied_alt);
    }
    if (points >= 18000 && points < 30000) {
      return const MapEntry('Enthusiast', Icons.emoji_events);
    }
    if (points >= 30000 && points < 38000) {
      return const MapEntry('Professional', Icons.work);
    }
    if (points >= 38000 && points < 50000) {
      return const MapEntry('Expert', Icons.star);
    }
    if (points >= 50000 && points < 100000) {
      return const MapEntry('Leader', Icons.leaderboard);
    }
    if (points >= 100000 && points < 500000) {
      return const MapEntry('Veteran', Icons.shield);
    }
    if (points >= 500000) return const MapEntry('Master', Icons.school);
    return const MapEntry("Great", Icons.error);
  }

  Future<void> saveRankToDatabase(String ethAddress) async {
    var db = await mongo.Db.create(
        'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');

    if (db.state == mongo.State.closed || db.state == mongo.State.init) {
      await db.open();
    }

    var userCollection = db.collection('users');

    try {
      await userCollection.update(
        mongo.where.eq('ethAddress', ethAddress),
        mongo.modify.set('totalPoints', totalPoints).set('rank', rankEntry.key),
        upsert: true,
      );
    } catch (e) {
      print('Error saving rank to database: $e');
    } finally {
      await db.close();
    }
  }

  Future<void> saveRankToLocal(int points, String rank) async {
    var box = await Hive.openBox('BeepoRankData');
    await box.put('totalPoints', points);
    await box.put('rank', rank);
  }

  Future<void> loadRankFromLocal() async {
    var box = await Hive.openBox('BeepoRankData');
    totalPoints = box.get('totalPoints', defaultValue: 0);
    // String rank = box.get('rank', defaultValue: 'Novice');
    rankEntry = setRank(totalPoints);
    notifyListeners();
  }
}
