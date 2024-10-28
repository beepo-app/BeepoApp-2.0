import 'package:Beepo/services/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

class UserProvider {
  Future<Map<String, dynamic>> getAllUsers() async {
    debugPrint('Fetching all users');
    try {
      // Check cache first
      var box = await Hive.openBox('Beepo2.0');
      var cachedUsers = box.get('allUsers');

      if (cachedUsers != null) {
        debugPrint('Returning cached users');
        return {'success': true, 'data': cachedUsers, 'source': 'cache'};
      }

      // If not in cache, fetch from Firebase
      Map<String, dynamic> result = await dbGetAllUsers();
      debugPrint('Users fetched result: $result');

      if (result['success'] == true && result['data'] != null) {
        List<Map<String, dynamic>> users = (result['data'] as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        // Update cache
        await box.put('allUsers', users);

        return {'success': true, 'data': users, 'source': 'database'};
      } else {
        debugPrint('No data or operation unsuccessful');
        return {
          'success': false,
          'error': 'No data returned or operation unsuccessful',
          'data': <Map<String, dynamic>>[],
        };
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return {
        'success': false,
        'error': e.toString(),
        'data': <Map<String, dynamic>>[],
      };
    }
  }
}
