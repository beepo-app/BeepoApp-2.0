import 'package:Beepo/services/database.dart';
// import 'package:Beepo/services/firebase_database.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:web3dart/web3dart.dart';

class AccountProvider extends ChangeNotifier {
  String? username;
  String? displayName;
  String? ethAddress;
  String? img;
  FirebaseFirestore? _db;
  FirebaseFirestore? get db => _db;

  // Initialize Firebase
  Future<void> initializeFirebase() async {
    // Ensure Firebase is initialized only once
    if (_db == null) {
      await Firebase.initializeApp();
      _db = FirebaseFirestore.instance;
      debugPrint('Connected to Firebase');
    }
  }

  //  Db? _db;

  // Db? get db => _db;

  // static const String _mongoUri =

  // 'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority';
  // Future<void> _ensureDbConnection() async {
  //   if (_db == null || !_db!.isConnected) {
  //     _db = await Db.create(_mongoUri);
  //     await _db!.open();
  //   }
  //   print('Connected to database');
  // }

  // Future<void> _ensureDbConnection() async {
  //   try {
  //     if (_db == null || _db!.state != State.open) {
  //       _db = await Db.create(_mongoUri);
  //       await _db!.open();
  //       debugPrint('Connected to database');
  //     } else {
  //       debugPrint('Already connected to database');
  //     }
  //   } catch (e) {
  //     debugPrint('Error connecting to database: $e');
  //     throw Exception('Failed to connect to database: $e');
  //   }
  // }

  Future<String> initDB() async {
    try {
      await initializeFirebase();
      // await _ensureDbConnection();
      notifyListeners();
      await getAllUsers();
      beepoPrint('DB init');
      return "DB init";
    } catch (e) {
      return ('Act Prov19  ${e.toString()}');
    }
  }

  Future<String> initAccountState() async {
    try {
      final box = Hive.box('Beepo2.0');
      var username_ = box.get('username') ?? "Unknown";
      var displayName_ = box.get('displayName') ?? "Unknown";
      var ethAddress_ = box.get('ethAddress') ?? "Unknown";
      String img_ = box.get('imageUrl') ?? "";

      username = username_;
      displayName = displayName_;
      ethAddress = ethAddress_;
      img = img_;

      notifyListeners();
      return "";
    } catch (e) {
      debugPrint("INITIATE ACCOUNT STATE:$e");
      return e.toString();
    }
  }

  // Future<Map<String, dynamic>> getAllUsers() async {
  //   debugPrint('Fetching all users');
  //   try {
  //     // Check cache first
  //     var box = await Hive.openBox('Beepo2.0');
  //     var cachedUsers = box.get('allUsers');

  //     if (cachedUsers != null) {
  //       debugPrint('Returning cached users');
  //       return {'success': true, 'data': cachedUsers, 'source': 'cache'};
  //     }

  //     // If not in cache, fetch from database
  //     await _ensureDbConnection();
  //     Map<String, dynamic> result = await dbGetAllUsers();
  //     debugPrint('Users fetched result: $result');

  //     if (result['success'] == true && result['data'] != null) {
  //       List<Map<String, dynamic>> users = (result['data'] as List)
  //           .map((item) => Map<String, dynamic>.from(item))
  //           .toList();

  //       // Update cache
  //       await box.put('allUsers', users);

  //       return {'success': true, 'data': users, 'source': 'database'};
  //     } else {
  //       debugPrint('No data or operation unsuccessful');
  //       return {
  //         'success': false,
  //         'error': 'No data returned or operation unsuccessful',
  //         'data': <Map<String, dynamic>>[],
  //       };
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetching users: $e');
  //     return {
  //       'success': false,
  //       'error': e.toString(),
  //       'data': <Map<String, dynamic>>[],
  //     };
  //   }
  // }

  Future<Map> getAllUsers() async {
    beepoPrint('running');
    try {
      beepoPrint('running 22222');
      Map data = await dbGetAllUsers(FirebaseFirestore.instance);
      beepoPrint("GET ALL USERS:$data");
      return {'success': "done"};
    } catch (e) {
      if (kDebugMode) {
        beepoPrint("E:$e");
        return ({'error': e.toString()});
      }
    }
    return ({'error': 'Not done'});
  }

  Future<Map<String, dynamic>> getUser(String username) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      // Query for the user by username
      QuerySnapshot querySnapshot = await db
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        debugPrint("USERDATA PRINT:$userData");
        return {'success': "done", 'data': userData};
      } else {
        return {'error': "User not found"};
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error: $e");
      }
      return {'error': e.toString()};
    }
  }

  Future<Map> getUserByAddress(EthereumAddress address) async {
    try {
      await initializeFirebase();
      // await _ensureDbConnection();
      // Map data = await dbGetUserByAddres( address);
      FirebaseFirestore db = FirebaseFirestore.instance;

      // Call the function with the correct parameters
      Map<String, dynamic> data = await dbGetUserByAddress(db, address);
      return data;
    } catch (e) {
      if (kDebugMode) {
        beepoPrint(e);
        return ({'error 63': e.toString()});
      }
    }
    return ({'error': 'Not done'});
  }

  Future<String> createUser(Uint8List base64Image, displayName, ethAddress,
      btcAddress, Encrypted encrypteData) async {
    try {
      await initializeFirebase();
      await dbCreateUser(
        base64Image,
        displayName,
        ethAddress,
        btcAddress,
        encrypteData,
      );
      return "done";
    } catch (e) {
      if (kDebugMode) {
        debugPrint("CREATE USER ERROR:$e");
        return (e.toString());
      }
    }
    return ('Not done');
  }

  Future<Map> updateUser(base64Image, displayName, bio, newUsername) async {
    try {
      await initializeFirebase();
      // await _ensureDbConnection();
      var data = await dbUpdateUser(
          base64Image, _db!, displayName, bio, newUsername, ethAddress);
      await initAccountState();
      if (data['error'] == null) {
        return {'success': data};
      } else {
        return {'error': data["error"]};
      }
    } catch (e) {
      if (kDebugMode) {
        beepoPrint(e);
        return ({'error': e.toString()});
      }
    }
    return ({'error': 'Not done'});
  }

  Future<Map> deleteUser() async {
    try {
      await initializeFirebase();
      // await _ensureDbConnection();
      var data = await dbDeleteUser(_db!, ethAddress);
      await initAccountState();
      if (data['error'] == null) {
        return {'success': data};
      } else {
        return {'error': data["error"]};
      }
    } catch (e) {
      if (kDebugMode) {
        beepoPrint(e);
        return ({'error': e.toString()});
      }
    }
    return ({'error': 'Not done'});
  }

  Stream<dynamic> findAndWatchAllUsers(FirebaseFirestore db) {
    return _useLookupStream(
      () async {
        await initializeFirebase();
        // await _ensureDbConnection();
        return dbGetAllUsers(db);
      },
      () async* {
        await initializeFirebase();
        // await _ensureDbConnection();
        yield* dbWatchAllUsers(db);
      },
    );
  }

  Stream<T> _useLookupStream<T>(
    Future<T> Function() find,
    Stream<T> Function() watch, [
    List<Object?> keys = const <Object>[],
  ]) =>
      StreamGroup.mergeBroadcast([find().asStream(), watch()]);

  Future<void> dispose() async {
    // await _db?.close();
    super.dispose();
  }
}
