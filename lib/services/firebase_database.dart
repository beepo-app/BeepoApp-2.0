import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future<Map<String, dynamic>> dbGetAllUsers() async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    var usersCollection = firestore.collection('users');

    debugPrint("GET USERS COLLECTION: $usersCollection");

    QuerySnapshot querySnapshot = await usersCollection.limit(10).get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("No users found");
    }

    List<Map<String, dynamic>> data = querySnapshot.docs
        .map((doc) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          return {
            'joined': userData['createdAt'],
            'username': userData['username'],
            'displayName': userData['displayName'],
            'ethAddress': userData['ethAddress'],
            'btcAddress': userData['btcAddress'],
            'image': userData['image'],
            'bio': userData['bio'],
          };
        })
        .where((item) => item.values.every((value) => value != null))
        .toList();

    if (data.isEmpty) {
      throw Exception("All user data was invalid");
    }

    debugPrint("GET USERS DATA: $data");
    return {'success': true, 'data': data};
  } catch (e) {
    debugPrint("ERROR MESSAGE: $e");
    return {'success': false, 'error': e.toString()};
  }
}
