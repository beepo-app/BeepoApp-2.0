// import 'package:Beepo/services/database.dart';
// import 'package:flutter/foundation.dart';
// import 'package:mongo_dart/mongo_dart.dart';

// class ActivityPoints extends ChangeNotifier {
//   Db db;
//   int _points = 0;
//   bool _isLoading = false;

//   ActivityPoints(this.db);

//   int get points => _points;
//   bool get isLoading => _isLoading;

//   Future<void> claimDailyPoints(String ethAddress) async {
//     _isLoading = true;
//     notifyListeners();

//     var result = await dbClaimDailyPoints(points, ethAddress);
//     if (result.containsKey('success')) {
//       _points += points;
//     } else {
//       debugPrint('Error claiming points: ${result['error']}');
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   void setPoints(int points) {
//     _points = points;
//     notifyListeners();
//   }

//   //

//   Future<void> withdrawPoints(String ethAddress) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       var result = await dbWithdrawPoints(ethAddress);
//       if (result.containsKey('success')) {
//         _points = 0;
//       } else {
//         debugPrint('Error withdrawing points: ${result['error']}');
//       }
//     } catch (e) {
//       debugPrint('Error withdrawing points: $e');
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   //
//   Future<void> updatePoints(int points, String ethAddress) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       var result = await dbUpdatePoints(points, ethAddress);
//       if (result.containsKey('success')) {
//         _points += points;
//       } else {
//         debugPrint('Error updating points: ${result['error']}');
//       }
//     } catch (e) {
//       debugPrint('Error updating points: $e');
//     }

//     _isLoading = false;
//     notifyListeners();
//   }
// }
