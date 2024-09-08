import 'package:Beepo/services/database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class NewPointsProvider with ChangeNotifier {
  int _points = 0;
  DateTime _lastClaim = DateTime.fromMillisecondsSinceEpoch(0);
  bool _canClaim = true;

  int get points => _points;
  bool get canClaim => _canClaim;

  int totalPoints = 0;

  void resetPoints() {
    totalPoints = 0;
    saveTotalPointsToHive();
    notifyListeners();
  }

  Future<void> saveTotalPointsToHive() async {
    var box = await Hive.openBox('BeepoRankData');
    await box.put('totalPoints', totalPoints);
  }

  NewPointsProvider() {
    fetchPoints();
  }

  Future<void> fetchPoints() async {
    var box = await Hive.openBox('Beepo2.0');
    var ethAddress = box.get('ethAddress');

    if (ethAddress != null) {
      // Fetch data from Hive first
      _points = box.get('points', defaultValue: 0);
      _lastClaim = box.get('lastClaim',
          defaultValue: DateTime.fromMillisecondsSinceEpoch(0));
      _canClaim = DateTime.now().difference(_lastClaim).inDays >= 1;

      // Then check the server for updates
      var db = await mongo.Db.create(
          'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');

      if (db.state == mongo.State.closed || db.state == mongo.State.init) {
        await db.open();
      }

      var pointsCollection = db.collection('points');
      var data = await pointsCollection
          .findOne(mongo.where.eq('ethAddress', ethAddress));

      if (data != null) {
        _points = data['points'];
        _lastClaim = data['lastClaim'];
        _canClaim = DateTime.now().difference(_lastClaim).inDays >= 1;

        // Save to Hive
        box.put('points', _points);
        box.put('lastClaim', _lastClaim);
        box.put('canClaim', _canClaim);
      } else {
        _points = 0;
        _canClaim = true;
      }
    } else {
      _points = 0;
      _canClaim = true;
    }

    notifyListeners();
  }

  Future<void> claimPoints(int points, String ethAddress) async {
    if (_canClaim) {
      await dbClaimDailyPoints(points, ethAddress);
      _points += points;
      _lastClaim = DateTime.now();
      _canClaim = false;

      // Save to Hive
      var box = await Hive.openBox('Beepo2.0');
      box.put('points', _points);
      box.put('lastClaim', _lastClaim);
      box.put('canClaim', _canClaim);

      notifyListeners();
    } else {
      print("Cannot claim points now, please come back later.");
    }
  }
}
