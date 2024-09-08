import 'package:Beepo/services/database.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class TimeBasedPointsProvider with ChangeNotifier {
  int _points = 0;
  int _timeSpent = 0; // Time spent in seconds

  int get points => _points;
  int get timeSpent => _timeSpent;

  void resetPoints() {
    _points = 0;
    savePointsToHive();
    notifyListeners();
  }

  Future<void> savePointsToHive() async {
    var box = await Hive.openBox('Beepo2.0');
    await box.put('timeBasedPoints', _points);
  }

  TimeBasedPointsProvider() {
    fetchTimeBasedPointsFromHive();
  }

  void updateTimeSpent(int timeInSeconds) {
    _timeSpent += timeInSeconds;

    // Save updated timeSpent to Hive
    var box = Hive.box('Beepo2.0');
    box.put('timeSpent', _timeSpent);

    notifyListeners();
  }

  Future<void> fetchPoints(String ethAddress) async {
    // Implement fetching logic from the server if needed
  }

  Future<void> fetchTimeBasedPointsFromHive() async {
    var box = await Hive.openBox('Beepo2.0');
    _points = box.get('points', defaultValue: 0);
    _timeSpent = box.get('timeSpent', defaultValue: 0);
    notifyListeners();
  }

  Future<void> addTimeBasedPoints(String ethAddress) async {
    await dbUpdateTimeBasedPoints(ethAddress, _timeSpent);

    // After points are added and time is reset on the server, update Hive
    _timeSpent = 0; // Reset after sending to the server

    // Save to Hive
    var box = await Hive.openBox('Beepo2.0');
    box.put('points', _points);
    box.put('timeSpent', _timeSpent);

    notifyListeners();
  }
}
