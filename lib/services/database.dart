import 'dart:math';
import 'package:Beepo/session/foreground_session.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web3dart/web3dart.dart';

// dbCreateUser(String image, Db db, String displayName, String ethAddress,
//     btcAddress, encrypteData) async {
//   if (db.state == State.closed) {
//     await db.open();
//   }

//   var usersCollection = db.collection('users');

//   List usernameArray = displayName.split(' ');
//   usernameArray.add((Random().nextInt(9900000) + 10000000).toString());
//   String username = usernameArray.join('_');

//   var val = await usersCollection.findOne(where.eq("username", username));

//   if (val == null) {
//     try {
//       await usersCollection.insertOne(
//         {
//           'username': username,
//           'displayName': displayName,
//           'ethAddress': ethAddress,
//           'btcAddress': btcAddress,
//           'image': image,
//           'createdAt': DateTime.now()
//         },
//       );

//       await Hive.box('Beepo2.0')
//           .put('encryptedSeedPhrase', (encrypteData.base64));
//       await Hive.box('Beepo2.0').put('base64Image', image);
//       await Hive.box('Beepo2.0').put('ethAddress', ethAddress);
//       await Hive.box('Beepo2.0').put('btcAddress', btcAddress);
//       await Hive.box('Beepo2.0').put('displayName', displayName);
//       await Hive.box('Beepo2.0').put('username', username);
//       await Hive.box('Beepo2.0').put('isSignedUp', true);
//     } catch (e) {
//       if (kDebugMode) {
//         beepoPrint(e);
//       }
//     }
//   } else {
//     await dbCreateUser(
//         image, db, displayName, ethAddress, btcAddress, encrypteData);
//   }

// }

Future<void> dbCreateUser(
  String image,
  String displayName,
  String ethAddress,
  String? btcAddress,
  Encrypted encrypteData,
) async {
  try {
    // Access Firestore instance directly
    final FirebaseFirestore db = FirebaseFirestore.instance;

    // Generate base username from displayName
    final String baseUsername = displayName.replaceAll(' ', '_');
    String username = '$baseUsername${Random().nextInt(9900000) + 10000000}';

    bool usernameExists = true;

    // Ensure username is unique
    while (usernameExists) {
      final userDoc = await db
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (userDoc.docs.isEmpty) {
        usernameExists = false; // Username is unique
      } else {
        // Generate a new random suffix if username already exists
        username = '$baseUsername${Random().nextInt(9900000) + 10000000}';
      }
    }

    // Prepare the data to send to Firestore
    Map<String, dynamic> userData = {
      'username': username,
      'displayName': displayName,
      'ethAddress': ethAddress,
      'image': image,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Only add btcAddress if it's not null
    if (btcAddress != null) {
      userData['btcAddress'] = btcAddress;
    }

    // Create user document in Firestore
    await db.collection('users').doc(username).set(userData);

    debugPrint("User document created in Firestore with username: $username");

    // Store user data in Hive for local persistence
    final box = Hive.box('Beepo2.0');
    await Future.wait([
      box.put('encryptedSeedPhrase', encrypteData.base64),
      box.put('base64Image', image),
      box.put('ethAddress', ethAddress),
      if (btcAddress != null) box.put('btcAddress', btcAddress),
      box.put('displayName', displayName),
      box.put('username', username),
      box.put('isSignedUp', true),
    ]);

    debugPrint("User data stored in Hive");
  } catch (e) {
    debugPrint("Error creating user: $e");
    throw Exception("Failed to create user: $e");
  }
}

// Stream<dynamic> dbWatchTx(Db db) {
//   if (db.state == State.closed) {
//     db.open();
//   }
//   var status = db.collection('status');

//   var update = status.watch(<Map<String, Object>>[
//     {
//       r'$match': {'operationType': 'update'}
//     }
//   ], changeStreamOptions: ChangeStreamOptions(fullDocument: 'updateLookup'));
//   var insert = status.watch(<Map<String, Object>>[
//     {
//       r'$match': {'operationType': 'insert'}
//     }
//   ], changeStreamOptions: ChangeStreamOptions(fullDocument: 'updateLookup'));

//   beepoPrint('watching all statueses 222');

//   return StreamGroup.mergeBroadcast([update, insert]);
// }

Stream<Map<String, dynamic>> dbWatchTx(FirebaseFirestore db) {
  CollectionReference statusCollection = db.collection('status');

  return statusCollection.snapshots().asyncExpand((snapshot) {
    // Filter for 'added' and 'modified' document changes only
    return Stream.fromIterable(
      snapshot.docChanges.where((change) =>
          change.type == DocumentChangeType.added ||
          change.type == DocumentChangeType.modified),
    ).map((change) => change.doc.data() as Map<String, dynamic>);
  });
}

// Stream<dynamic> dbWatchAllStatus(Db db) {
//   if (db.state == State.closed) {
//     db.open();
//   }
//   var status = db.collection('status');

//   var update = status.watch(<Map<String, Object>>[
//     {
//       r'$match': {'operationType': 'update'}
//     }
//   ], changeStreamOptions: ChangeStreamOptions(fullDocument: 'updateLookup'));
//   var insert = status.watch(<Map<String, Object>>[
//     {
//       r'$match': {'operationType': 'insert'}
//     }
//   ], changeStreamOptions: ChangeStreamOptions(fullDocument: 'updateLookup'));

//   beepoPrint('watching all statueses 222');

//   return StreamGroup.mergeBroadcast([update, insert]);
// }

Stream<Map<String, dynamic>> dbWatchAllStatus(FirebaseFirestore db) {
  // Reference the 'status' collection in Firestore
  CollectionReference statusCollection = db.collection('status');

  // Listen to changes in the 'status' collection
  return statusCollection.snapshots().asyncExpand((snapshot) {
    // Filter only for 'added' and 'modified' document changes
    return Stream.fromIterable(
      snapshot.docChanges.where((change) =>
          change.type == DocumentChangeType.added ||
          change.type == DocumentChangeType.modified),
    ).map((change) => change.doc.data() as Map<String, dynamic>);
  });
}

Future<List<Map<String, dynamic>>> dbGetAllStatus(FirebaseFirestore db) async {
  // Reference the 'status' collection in Firestore
  CollectionReference statusCollection = db.collection('status');

  try {
    // Query for documents where 'expireAt' is less than the current time
    QuerySnapshot querySnapshot = await statusCollection
        .where('expireAt', isLessThan: DateTime.now())
        .get();

    // Map each document in the result to its data as a Map
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  } catch (e) {
    throw {"error": e.toString()};
  }
}

// Future<List<dynamic>> dbGetAllStatus(Db db) async {
//   if (db.state == State.closed) {
//     await db.open();
//   }
//   var status = db.collection('status');
//   return status.find({
//     "expireAt": {r'$lt': DateTime.now()}
//   }).toList();
// }

// Future<List<dynamic>> dbGetAllPoints(Db db) async {
//   if (db.state == State.closed) {
//     await db.open();
//   }
//   var status = db.collection('points');
//   return status.find({
//     "expireAt": {r'$lt': DateTime.now()}
//   }).toList();
// }

Future<List<Map<String, dynamic>>> dbGetAllPoints(FirebaseFirestore db) async {
  CollectionReference pointsCollection = db.collection('points');

  try {
    // Query documents where 'expireAt' is less than the current date and time
    QuerySnapshot querySnapshot = await pointsCollection
        .where("expireAt", isLessThan: DateTime.now())
        .get();

    // Map the documents to a list of Maps
    List<Map<String, dynamic>> points = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    return points;
  } catch (e) {
    debugPrint('Error fetching points: $e');
    return [];
  }
}

// dbDeleteStatus(Db db, newData, String ethAddress) async {
//   if (db.state == State.closed) {
//     await db.open();
//   }
//   var status = db.collection('status');
//   beepoPrint(newData?.length);
//   try {
//     var d;
//     if (newData?.length <= 1) {
//       d = await status.deleteOne(where.eq("ethAddress", ethAddress));
//       showToast('Deleted Successfully!');
//       return;
//     }
//     beepoPrint('deleting');
//     d = await status.updateOne(
//       where.eq("ethAddress", ethAddress),
//       ModifierBuilder().set('data', newData),
//       writeConcern: WriteConcern.majority,
//     );
//     showToast('Deleted Successfully!');
//   } catch (e) {
//     if (kDebugMode) {
//       beepoPrint(e);
//     }
//   }
// }

Future<void> dbDeleteStatus(
    FirebaseFirestore db, List<dynamic>? newData, String ethAddress) async {
  CollectionReference statusCollection = db.collection('status');

  try {
    // Query for the document with the matching ethAddress
    QuerySnapshot querySnapshot = await statusCollection
        .where("ethAddress", isEqualTo: ethAddress)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference docRef = querySnapshot.docs.first.reference;

      // If newData has 1 or fewer items, delete the document
      if (newData == null || newData.length <= 1) {
        await docRef.delete();
        showToast('Deleted Successfully!');
      } else {
        // Otherwise, update the 'data' field with newData
        await docRef.update({'data': newData});
        showToast('Updated Successfully!');
      }
    } else {
      showToast('Document not found');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error updating/deleting status: $e');
    }
  }
}

// dbAutoDeleteStatus(Db db, newData, String ethAddress) async {
//   if (db.state == State.closed) {
//     await db.open();
//   }
//   var status = db.collection('status');

//   try {
//     var d;
//     if (newData?.length <= 1) {
//       d = await status.deleteOne(where.eq("ethAddress", ethAddress));
//       showToast('Deleted Successfully!');
//       return;
//     }
//     beepoPrint('deleting');
//     d = await status.updateOne(
//       where.eq("ethAddress", ethAddress),
//       ModifierBuilder().set('data', newData),
//       writeConcern: WriteConcern.majority,
//     );
//     showToast('Deleted Successfully!');
//   } catch (e) {
//     if (kDebugMode) {
//       beepoPrint(e);
//     }
//   }
// }

Future<void> dbAutoDeleteStatus(FirebaseFirestore db,
    Map<String, dynamic>? newData, String ethAddress) async {
  // Reference the 'status' collection in Firestore
  CollectionReference statusCollection = db.collection('status');

  try {
    // Query the document with matching ethAddress
    QuerySnapshot querySnapshot = await statusCollection
        .where('ethAddress', isEqualTo: ethAddress)
        .limit(1)
        .get();

    // Check if the document exists
    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference docRef = querySnapshot.docs.first.reference;

      // If newData has 1 or fewer items, delete the document
      if (newData == null || newData.length <= 1) {
        await docRef.delete();
        showToast('Deleted Successfully!');
      } else {
        // Otherwise, update the 'data' field in the document
        await docRef.update({'data': newData});
        showToast('Updated Successfully!');
      }
    } else {
      showToast('Document Not Found');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
  }
}

// dbUpdateStatusViewsCount(
//     Db db, String id, String ethAddress, String viewerAddress) async {
//   if (db.state == State.closed) {
//     await db.open();
//   }

//   var status = db.collection('status');
//   var data = await status.findOne(where.eq('ethAddress', ethAddress));

//   if (data == null) {
//     return;
//   }

//   List viewers = data['viewers'];
//   viewers.add(viewerAddress);

//   try {
//     var d = await status.updateOne(
//       where.eq("ethAddress", ethAddress),
//       ModifierBuilder().set('viewers', viewers),
//       writeConcern: WriteConcern.majority,
//     );
//   } catch (e) {
//     if (kDebugMode) {
//       beepoPrint(e);
//     }
//   }
// }

Future<void> dbUpdateStatusViewsCount(FirebaseFirestore db, String id,
    String ethAddress, String viewerAddress) async {
  CollectionReference statusCollection = db.collection('status');

  try {
    // Query the document with the specified ethAddress
    QuerySnapshot querySnapshot = await statusCollection
        .where('ethAddress', isEqualTo: ethAddress)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference docRef = querySnapshot.docs.first.reference;
      Map<String, dynamic> data =
          querySnapshot.docs.first.data() as Map<String, dynamic>;

      // Retrieve current viewers list, add viewerAddress if not already present
      List<dynamic> viewers = data['viewers'] ?? [];
      if (!viewers.contains(viewerAddress)) {
        await docRef.update({
          'viewers': FieldValue.arrayUnion([viewerAddress])
        });
      }
    } else {
      if (kDebugMode) {
        print('No document found with ethAddress: $ethAddress');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error updating viewers: $e');
    }
  }
}

// dbUploadStatus(String image, Db db, String message, String privacy,
//     String ethAddress) async {
//   if (db.state == State.closed) {
//     await db.open();
//   }
//   var status = db.collection('status');

//   var data = await status.findOne(where.eq('ethAddress', ethAddress));

//   if (data == null) {
//     try {
//       status.createIndex(keys: {'expireAt': 1, 'expireAfterSeconds': 5000});
//       DateTime finalTime =
//           DateTime.now().add(const Duration(hours: 3, minutes: 0, seconds: 0));

//       var d = await status.insertOne(
//         {
//           'ethAddress': ethAddress,
//           'data': [
//             {
//               'privacy': privacy,
//               'message': message,
//               'ethAddress': ethAddress,
//               'image': image,
//               "expireAt": finalTime,
//               'createdAt': DateTime.now(),
//               "id": "$ethAddress-0"
//             }
//           ],
//           "viewers": [],
//         },
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         beepoPrint(e);
//       }
//     }

//     showToast('Uploaded Successfully!');
//     return;
//   }

//   List oldData = data['data'];
//   DateTime finalTime =
//       DateTime.now().add(const Duration(hours: 3, minutes: 0, seconds: 59));

//   oldData.add({
//     'privacy': privacy,
//     'message': message,
//     'ethAddress': ethAddress,
//     'image': image,
//     "expireAt": finalTime,
//     'createdAt': DateTime.now(),
//     "id": "$ethAddress-${oldData.length}"
//   });

//   try {
//     var d = await status.updateOne(
//       where.eq("ethAddress", ethAddress),
//       ModifierBuilder().set('data', oldData),
//       writeConcern: WriteConcern.majority,
//     );
//     showToast('Uploaded Successfully!');
//   } catch (e) {
//     if (kDebugMode) {
//       beepoPrint(e);
//     }
//   }
// }

Future<void> dbUploadStatus(
  String image,
  FirebaseFirestore db,
  String message,
  String privacy,
  String ethAddress,
) async {
  CollectionReference statusCollection = db.collection('status');

  try {
    // Query for an existing document with the specified ethAddress
    QuerySnapshot querySnapshot = await statusCollection
        .where('ethAddress', isEqualTo: ethAddress)
        .limit(1)
        .get();

    DateTime finalTime = DateTime.now().add(const Duration(hours: 3));
    DateTime createdAt = DateTime.now();

    if (querySnapshot.docs.isEmpty) {
      // Create a new document if one does not exist
      await statusCollection.doc(ethAddress).set({
        'ethAddress': ethAddress,
        'data': [
          {
            'privacy': privacy,
            'message': message,
            'ethAddress': ethAddress,
            'image': image,
            'expireAt': finalTime,
            'createdAt': createdAt,
            'id': "$ethAddress-0",
          }
        ],
        'viewers': [],
      });
      showToast('Uploaded Successfully!');
    } else {
      // If the document exists, add to the 'data' array
      DocumentReference docRef = querySnapshot.docs.first.reference;
      List<dynamic> oldData =
          (querySnapshot.docs.first.data() as Map<String, dynamic>)['data'] ??
              [];

      oldData.add({
        'privacy': privacy,
        'message': message,
        'ethAddress': ethAddress,
        'image': image,
        'expireAt': finalTime,
        'createdAt': createdAt,
        'id': "$ethAddress-${oldData.length}",
      });

      await docRef.update({'data': oldData});
      showToast('Uploaded Successfully!');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint("Error uploading status: $e");
    }
  }
}

// Future<Map<String, dynamic>> dbDeleteUser(Db db, ethAddress) async {
//   await db.open();
//   var usersCollection = db.collection('users');
//   var status = db.collection('status');

//   try {
//     var d = await usersCollection.deleteOne(where.eq("ethAddress", ethAddress));
//     beepoPrint(d);
//     d = await status.deleteOne(where.eq("ethAddress", ethAddress));
//     showToast('Account Deleted Successfully!');
//     session.clear();
//     Hive.deleteBoxFromDisk("Beepo2.0");
//     beepoPrint(d);
//   } catch (e) {
//     if (kDebugMode) {
//       beepoPrint(e);
//     }
//   }

//   return ({'error': "An error occured!"});
// }

Future<Map<String, dynamic>> dbDeleteUser(
    FirebaseFirestore db, ethAddress) async {
  CollectionReference usersCollection = db.collection('users');
  CollectionReference statusCollection = db.collection('status');

  try {
    // Delete the user document from the 'users' collection
    QuerySnapshot userSnapshot = await usersCollection
        .where("ethAddress", isEqualTo: ethAddress)
        .limit(1)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      await userSnapshot.docs.first.reference.delete();
    }

    // Delete all documents in 'status' collection with the matching ethAddress
    QuerySnapshot statusSnapshot =
        await statusCollection.where("ethAddress", isEqualTo: ethAddress).get();

    for (var doc in statusSnapshot.docs) {
      await doc.reference.delete();
    }

    // Clear session data, delete Hive box, and show a success message
    showToast('Account Deleted Successfully!');
    session.clear();
    await Hive.deleteBoxFromDisk("Beepo2.0");

    return {'success': "Account deletion completed."};
  } catch (e) {
    if (kDebugMode) {
      print("Error deleting user: $e");
    }
    return {'error': e.toString()};
  }
}

// Future<Map<String, dynamic>> dbUpdateUser(
//     image, Db db, displayName, bio, newUsername, ethAddress) async {
//   await db.open();
//   var usersCollection = db.collection('users');

//   var oldData =
//       await usersCollection.findOne(where.eq("username", newUsername));

//   if (oldData == null) {
//     try {
//       Map<String, dynamic>? newData =
//           await usersCollection.findOne(where.eq("ethAddress", ethAddress));
//       if (newData != null) {
//         newData['username'] = newUsername;
//         newData['displayName'] = displayName;
//         newData['bio'] = bio;
//         newData['image'] = image;

//         await usersCollection.replaceOne(
//             where.eq("ethAddress", ethAddress), newData);

//         await Hive.box('Beepo2.0').put('base64Image', image);
//         await Hive.box('Beepo2.0').put('displayName', displayName);
//         await Hive.box('Beepo2.0').put('username', newUsername);
//         await Hive.box('Beepo2.0').put('bio', bio);
//         return (newData);
//       } else {
//         throw ({'error': "An error occured here!"});
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         beepoPrint(e);
//       }
//     }
//   } else {
//     throw ({'error': "Username Already exists!"});
//   }
//   // await db.close();
//   return ({'error': "An error occured!"});
// }

Future<Map<String, dynamic>> dbUpdateUser(
  String image,
  FirebaseFirestore db,
  String displayName,
  String bio,
  String newUsername,
  ethAddress,
) async {
  CollectionReference usersCollection = db.collection('users');

  try {
    // Check if the username already exists
    QuerySnapshot usernameSnapshot = await usersCollection
        .where("username", isEqualTo: newUsername)
        .limit(1)
        .get();

    if (usernameSnapshot.docs.isNotEmpty) {
      throw {'error': "Username Already exists!"};
    }

    // Retrieve the user's document by ethAddress
    QuerySnapshot userSnapshot = await usersCollection
        .where("ethAddress", isEqualTo: ethAddress)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) {
      throw {'error': "User not found!"};
    }

    DocumentReference userDocRef = userSnapshot.docs.first.reference;
    Map<String, dynamic> newData =
        userSnapshot.docs.first.data() as Map<String, dynamic>;

    // Update the fields
    newData['username'] = newUsername;
    newData['displayName'] = displayName;
    newData['bio'] = bio;
    newData['image'] = image;

    // Update the document in Firestore
    await userDocRef.update(newData);

    // Update local Hive storage
    await Hive.box('Beepo2.0').put('base64Image', image);
    await Hive.box('Beepo2.0').put('displayName', displayName);
    await Hive.box('Beepo2.0').put('username', newUsername);
    await Hive.box('Beepo2.0').put('bio', bio);

    return newData;
  } catch (e) {
    if (kDebugMode) {
      print("Error updating user: $e");
    }
    throw {'error': "An error occurred!"};
  }
}

// Future<Map<String, dynamic>> dbGetAllUsers(Db db) async {
//   try {
//     if (db.state == State.closed) {
//       await db.open();
//     }
//     beepoPrint('fetching db: $db');
//     beepoPrint('fetching users');
//     var usersCollection = db.collection('users');
//     beepoPrint('users collection: $usersCollection');

//     List<Map<String, dynamic>>? val =
//         await usersCollection.find().take(10).toList();
//     debugPrint("about calling dbgetallusers");

//     if (val.isEmpty) {
//       debugPrint("val is empty");
//       throw Exception("No users found");
//     }

//     List<Map<String, dynamic>> data = val
//         .map((e) => {
//               'joined': e['createdAt'],
//               'username': e['username'],
//               'displayName': e['displayName'],
//               'ethAddress': e['ethAddress'],
//               'btcAddress': e['btcAddress'],
//               'image': e['image'],
//               'bio': e['bio'],
//             })
//         .toList();

//     // Filter out any null entries
//     data = data
//         .where((item) => item.values.every((value) => value != null))
//         .toList();

//     if (data.isEmpty) {
//       print("All user data was null");
//       throw Exception("All user data was invalid");
//     }

//     await Hive.box('Beepo2.0').put('allUsers', data);
//     return {'success': "done", "data": data};
//   } catch (e) {
//     beepoPrint("ERROR MESSAGE: $e");
//     return {'error': e.toString()};
//   }
// }

Future<Map<String, dynamic>> dbGetAllUsers(FirebaseFirestore db) async {
  try {
    // Query the first 10 documents in the 'users' collection
    QuerySnapshot querySnapshot = await db.collection('users').limit(10).get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("No users found");
    }

    // Map each document to the desired data structure
    List<Map<String, dynamic>> data = querySnapshot.docs.map((doc) {
      Map<String, dynamic> e = doc.data() as Map<String, dynamic>;
      return {
        'joined': e['createdAt'],
        'username': e['username'],
        'displayName': e['displayName'],
        'ethAddress': e['ethAddress'],
        'btcAddress': e['btcAddress'],
        'image': e['image'],
        'bio': e['bio'],
      };
    }).toList();

    // Filter out entries with null values
    data = data
        .where((item) => item.values.every((value) => value != null))
        .toList();

    if (data.isEmpty) {
      throw Exception("All user data was invalid");
    }

    // Store the data in Hive for offline access
    await Hive.box('Beepo2.0').put('allUsers', data);

    return {'success': "done", "data": data};
  } catch (e) {
    if (kDebugMode) {
      print("ERROR MESSAGE: $e");
    }
    return {'error': e.toString()};
  }
}

Stream<Map<String, dynamic>> dbWatchAllUsers(FirebaseFirestore db) {
  // Reference the 'users' collection
  CollectionReference usersCollection = db.collection('users');

  // Listen to changes in the 'users' collection
  return usersCollection.snapshots().asyncExpand((snapshot) {
    // Map DocumentChanges to return only 'added' and 'modified' types
    return Stream.fromIterable(
      snapshot.docChanges.where((change) =>
          change.type == DocumentChangeType.added ||
          change.type == DocumentChangeType.modified),
    ).map((change) => change.doc.data() as Map<String, dynamic>);
  });
}
// Stream<dynamic> dbWatchAllUsers(Db db) {
//   if (db.state == State.closed) {
//     db.open();
//   }
//   var status = db.collection('users');

//   var update = status.watch(<Map<String, Object>>[
//     {
//       r'$match': {'operationType': 'update'}
//     }
//   ], changeStreamOptions: ChangeStreamOptions(fullDocument: 'updateLookup'));
//   var insert = status.watch(<Map<String, Object>>[
//     {
//       r'$match': {'operationType': 'insert'}
//     }
//   ], changeStreamOptions: ChangeStreamOptions(fullDocument: 'updateLookup'));

//   return StreamGroup.mergeBroadcast([update, insert]);
// }

// Future<Map> dbGetUser(Db db, String username) async {
//   await db.open();
//   var usersCollection = db.collection('users');

//   Map? val = await usersCollection.findOne(where.eq("username", username));

//   if (val == null) {
//     // await db.close();
//     throw ("User Not Found");
//   } else {
//     // await db.close();
//     return {'success': "done", "data": val};
//   }
// }

Future<Map<String, dynamic>> dbGetUser(
    FirebaseFirestore db, String username) async {
  // Reference the 'users' collection in Firestore
  CollectionReference usersCollection = db.collection('users');

  try {
    // Query for the document with matching username
    QuerySnapshot querySnapshot = await usersCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw "User Not Found";
    } else {
      return {
        'success': "done",
        'data': querySnapshot.docs.first.data() as Map<String, dynamic>
      };
    }
  } catch (e) {
    throw {"error": e.toString()};
  }
}

// Future<Map> dbGetUserByAddres(Db db, EthereumAddress ethAddress) async {
//   await db.open();
//   var usersCollection = db.collection('users');
//   try {
//     Map? val = await usersCollection
//         .findOne(where.eq("ethAddress", ethAddress.toString()));

//     if (val == null) {
//       // await db.close();
//       return {'error': "User Not Found"};
//     } else {
//       // await db.close();
//       return val;
//     }
//   } catch (e) {
//     return {'error acctProv': e};
//   }
// }

Future<Map<String, dynamic>> dbGetUserByAddress(
    FirebaseFirestore db, EthereumAddress ethAddress) async {
  try {
    // Reference the 'users' collection in Firestore
    CollectionReference usersCollection = db.collection('users');

    // Query for the document with matching ethAddress
    QuerySnapshot querySnapshot = await usersCollection
        .where('ethAddress', isEqualTo: ethAddress)
        .limit(1) // Use limit for efficiency, since only one user is expected
        .get();

    if (querySnapshot.docs.isEmpty) {
      // If no user found, return an error
      debugPrint("User Not Found Error");
      return {'error': "User Not Found"};
    } else {
      // Return the data of the first matching user document
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    }
  } catch (e) {
    debugPrint("error acctProv': ${e.toString()}");
    // Return error if the Firestore query fails
    return {'error acctProv': e.toString()};
  }
}

Future<void> dbClaimDailyPoints(int points, String ethAddress) async {
  var db = await Db.create(
      'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');

  if (db.state == State.closed || db.state == State.init) {
    await db.open();
  }

  var pointsCollection = db.collection('points');

  var data = await pointsCollection.findOne(where.eq('ethAddress', ethAddress));

  if (data == null) {
    try {
      await pointsCollection.insertOne(
        {
          'ethAddress': ethAddress,
          "points": points,
          "lastClaim": DateTime.now(),
          'referrals': 0
        },
      );
      var box = await Hive.openBox('Beepo2.0');
      await box.put('ethAddress', ethAddress);
      await box.put('points', points);
    } catch (e) {
      debugPrint("E$e");
    }
    return;
  }

  DateTime lastClaim =
      data['lastClaim'] ?? DateTime.fromMillisecondsSinceEpoch(0);
  DateTime now = DateTime.now();
  if (now.difference(lastClaim).inDays >= 1) {
    data['points'] = data['points'] + points;
    data['lastClaim'] = now;
    try {
      await pointsCollection.replaceOne(
          where.eq("ethAddress", ethAddress), data);
      debugPrint('Daily points claimed successfully!');
    } catch (e) {
      debugPrint("E$e");
    }
  } else {
    debugPrint("Please come back later!");
  }
}

dbWithdrawPoints(String ethAddress) async {
  Db db = await Db.create(
      'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');

  if (db.state == State.closed || db.state == State.init) {
    await db.open();
  }

  var pointsCollection = db.collection('points');

  var data = await pointsCollection.findOne(where.eq('ethAddress', ethAddress));

  if (data == null) {
    try {
      return {'error': "data not found"};
    } catch (e) {
      beepoPrint(e);
    }
    await Hive.box('Beepo2.0').put('ethAddress', ethAddress);
    return;
  }

  data['points'] = 0;

  try {
    var d = await pointsCollection.replaceOne(
        where.eq("ethAddress", ethAddress), data);
    beepoPrint('Points Withdrwn Successfully!');
    return dbFetchPoints(ethAddress);
  } catch (e) {
    beepoPrint(e);
  }
}

dbUpdatePoints(int points, String ethAddress) async {
  Db db = await Db.create(
      'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');

  if (db.state == State.closed || db.state == State.init) {
    await db.open();
  }

  var pointsCollection = db.collection('points');

  var data = await pointsCollection.findOne(where.eq('ethAddress', ethAddress));

  if (data == null) {
    try {
      var d = await pointsCollection.insertOne(
        {
          'ethAddress': ethAddress,
          "points": points,
          "lastClaim": DateTime.now(),
          'referrals': 0
        },
      );
      await Hive.box('Beepo2.0').put('ethAddress', ethAddress);
      await Hive.box('Beepo2.0').put('ethAddress', points);
    } catch (e) {
      beepoPrint(e);
    }
    return;
  }

  data['points'] = data['points'] + points;

  try {
    var d = await pointsCollection.replaceOne(
        where.eq("ethAddress", ethAddress), data);

    return dbFetchPoints(ethAddress);
  } catch (e) {
    beepoPrint(e);
  }

//   beepoPrint('Please come back after 24 hours!');
}

dbFetchPoints(String ethAddress) async {
  Db db = await Db.create(
      'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');

  if (db.state == State.closed || db.state == State.init) {
    await db.open();
  }

  beepoPrint('running fetch points');
  var pointsCollection = db.collection('points');

  var data = await pointsCollection.findOne(where.eq('ethAddress', ethAddress));

  if (data == null) {
    try {
      return {"error": 'not found'};
    } catch (e) {
      beepoPrint(e);
    }
  }

  try {
    return data;
  } catch (e) {
    beepoPrint(e);
  }
}

Future<Map<String, dynamic>> dbUpdateReferrals(String refId) async {
  var db = await Db.create(
      'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');

  if (db.state == State.closed || db.state == State.init) {
    await db.open();
  }

  var pointsCollection = db.collection('points');
  var usersCollection = db.collection('users');

  var user = await usersCollection.findOne(where.eq('username', refId));

  if (user == null) {
    return {"error": 'User not found'};
  }

  var ethAddress = user['ethAddress'];
  var pointsData =
      await pointsCollection.findOne(where.eq('ethAddress', ethAddress));

  if (pointsData == null) {
    try {
      await pointsCollection.insertOne({
        'ethAddress': ethAddress,
        "points": 100, // Initial points for a new referral
        'referrals': 1,
      });
    } catch (e) {
      debugPrint("E $e");
      return {"error": e.toString()};
    }
  } else {
    pointsData['points'] = pointsData['points'] + 100;
    pointsData['referrals'] = pointsData['referrals'] + 1;

    try {
      await pointsCollection.replaceOne(
          where.eq("ethAddress", ethAddress), pointsData);
    } catch (e) {
      debugPrint("E $e");
      return {"error": e.toString()};
    }
  }

  return {"success": 'Referral added successfully!'};
}

Future<Map<String, dynamic>?> dbFetchReferrals(String ethAddress) async {
  var db = await Db.create(
      'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');

  if (db.state == State.closed || db.state == State.init) {
    await db.open();
  }

  var pointsCollection = db.collection('points');

  try {
    var data =
        await pointsCollection.findOne(where.eq('ethAddress', ethAddress));
    return data;
  } catch (e) {
    debugPrint("Error fetching referrals: $e");
    return null;
  } finally {
    await db.close();
  }
}

//HOURS STAY 3

Future<void> dbUpdateTimeBasedPoints(String ethAddress, int timeSpent) async {
  var db = await Db.create(
      'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');

  if (db.state == State.closed || db.state == State.init) {
    await db.open();
  }

  var pointsCollection = db.collection('points');

  var pointsData =
      await pointsCollection.findOne(where.eq('ethAddress', ethAddress));

  if (pointsData == null) {
    try {
      await pointsCollection.insertOne({
        'ethAddress': ethAddress,
        'points': 0,
        'timeSpent': 0,
      });
    } catch (e) {
      debugPrint("Error creating initial points data: $e");
      return;
    }
  } else {
    pointsData['timeSpent'] = (pointsData['timeSpent'] ?? 0) + timeSpent;

    if (pointsData['timeSpent'] >= 3 * 3600) {
      // 3 hours = 3 * 3600 seconds
      pointsData['points'] =
          pointsData['points'] + 300; // Add points for 3 hours spent
      pointsData['timeSpent'] = 0; // Reset time spent after awarding points

      // Update the local _points variable and save to Hive
      var box = await Hive.openBox('Beepo2.0');
      box.put('points', pointsData['points']);
    }

    try {
      await pointsCollection.replaceOne(
          where.eq('ethAddress', ethAddress), pointsData);
    } catch (e) {
      debugPrint("Error updating points data: $e");
    }
  }
}

//AWARD TWEET
Future<void> dbAwardTweetPoints(String ethAddress, int points) async {
  var db = await Db.create(
      'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');

  if (db.state == State.closed || db.state == State.init) {
    await db.open();
  }

  var pointsCollection = db.collection('points');

  var pointsData =
      await pointsCollection.findOne(where.eq('ethAddress', ethAddress));

  if (pointsData == null) {
    try {
      await pointsCollection.insertOne({
        'ethAddress': ethAddress,
        'points': points,
      });
    } catch (e) {
      debugPrint("Error creating points data: $e");
      return;
    }
  } else {
    pointsData['points'] = (pointsData['points'] ?? 0) + points;

    try {
      await pointsCollection.replaceOne(
          where.eq('ethAddress', ethAddress), pointsData);
    } catch (e) {
      debugPrint("Error updating points data: $e");
    }
  }
  await db.close();
}

Future<void> dbUpdateActiveTime(String ethAddress, int activeTimeToAdd) async {
  Db db = await Db.create(
      'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');

  if (db.state == State.closed || db.state == State.init) {
    await db.open();
  }

  var pointsCollection = db.collection('points');
  var data = await pointsCollection.findOne(where.eq('ethAddress', ethAddress));

  if (data == null) {
    try {
      await pointsCollection.insertOne({
        'ethAddress': ethAddress,
        'points': 0,
        'lastClaim': DateTime.now(),
        'referrals': 0,
        'dailyActiveTime': activeTimeToAdd,
        'lastActiveCheck': DateTime.now(),
      });
      dbFetchPoints(ethAddress);
    } catch (e) {
      beepoPrint(e);
    }
    return;
  }

  DateTime lastActiveCheck =
      (data['lastActiveCheck'] as DateTime?) ?? DateTime.now();
  int dailyActiveTime = data['dailyActiveTime'] ?? 0;

  if (lastActiveCheck.day != DateTime.now().day) {
    dailyActiveTime = 0; // Reset daily active time if it's a new day
  }

  dailyActiveTime += activeTimeToAdd;
  data['dailyActiveTime'] = dailyActiveTime;
  data['lastActiveCheck'] = DateTime.now();

  if (dailyActiveTime >= 10800) {
    // 10800 seconds = 3 hours
    data['points'] = data['points'] + 500; // Reward 500 points
    data['dailyActiveTime'] = 0; // Reset active time after rewarding
    showToast(
        "Congrats you've earned 500 points for staying active for 3 hours on Beepo today.");
  }

  try {
    await pointsCollection.replaceOne(where.eq("ethAddress", ethAddress), data);
    await Hive.box('Beepo2.0').put('points', data['points']);
    await Hive.box('Beepo2.0').put('dailyActiveTime', data['dailyActiveTime']);
    showToast("Active time updated successfully!");
    beepoPrint('Active time updated successfully!');
  } catch (e) {
    beepoPrint(e);
  }
}


// String setRank(int points) {
//   if (points < 5000) return 'Novice';
//   if (points >= 5000 && points < 10000) return 'Amateur';
//   if (points >= 10000 && points < 18000) return 'Senior';
//   if (points >= 18000 && points < 30000) return 'Enthusiast';
//   if (points >= 30000 && points < 38000) return 'Professional';
//   if (points >= 38000 && points < 50000) return 'Expert';
//   if (points >= 50000 && points < 100000) return 'Leader';
//   if (points >= 100000 && points < 500000) return 'Veteran';
//   if (points >= 500000) return 'Master';
//   return "";
// }
