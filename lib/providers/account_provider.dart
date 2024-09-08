import 'package:Beepo/services/database.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:web3dart/web3dart.dart';

class AccountProvider extends ChangeNotifier {
  String? username;
  String? displayName;
  String? ethAddress;
  String? img;
  Db? db;

  Future<String> initDB() async {
    try {
      db = await Db.create(
          'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');
      await db!.open();
      notifyListeners();
      getAllUsers();
      beepoPrint('DB init');
      return "DB init";
    } catch (e) {
      return ('Act Prov19  ${e.toString()}');
    }
  }

  Future<String> initAccountState() async {
    var username_ = await Hive.box('Beepo2.0').get('username');
    var displayName_ = await Hive.box('Beepo2.0').get('displayName');
    var ethAddress_ = await Hive.box('Beepo2.0').get('ethAddress');
    String img_ = Hive.box('Beepo2.0').get('base64Image');
    try {
      username = username_;
      displayName = displayName_;
      ethAddress = ethAddress_;
      img = img_;
      notifyListeners();
      return "";
    } catch (e) {
      return (e.toString());
    }
  }

  Future<Map> getAllUsers() async {
    beepoPrint('running');
    try {
      beepoPrint('running 22222');
      Map data = await dbGetAllUsers(db!);
      beepoPrint(data);
      return {'success': "done"};
    } catch (e) {
      if (kDebugMode) {
        beepoPrint(e);
        return ({'error': e.toString()});
      }
    }
    return ({'error': 'Not done'});
  }

  Future<Map> getUser() async {
    try {
      db ??= await Db.create(
          'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');
      Map data = await dbGetUser(db!, username!);
      beepoPrint(data);
      return {'success': "done"};
    } catch (e) {
      if (kDebugMode) {
        beepoPrint(e);
        return ({'error': e.toString()});
      }
    }
    return ({'error': 'Not done'});
  }

  Future<Map> getUserByAddress(EthereumAddress address) async {
    try {
      db ??= await Db.create(
          'mongodb+srv://admin:admin1234@cluster0.x31efel.mongodb.net/?retryWrites=true&w=majority');
      Map data = await dbGetUserByAddres(db!, address);
      return data;
    } catch (e) {
      if (kDebugMode) {
        beepoPrint(e);
        return ({'error 63': e.toString()});
      }
    }
    return ({'error': 'Not done'});
  }

  Future<String> createUser(base64Image, db, displayName, ethAddress,
      btcAddress, encrypteData) async {
    try {
      await dbCreateUser(
          base64Image, db, displayName, ethAddress, btcAddress, encrypteData);

      return "done";
    } catch (e) {
      if (kDebugMode) {
        beepoPrint(e);
        return (e.toString());
      }
    }
    return ('Not done');
  }

  Future<Map> updateUser(base64Image, db, displayName, bio, newUsername) async {
    try {
      var data = await dbUpdateUser(
          base64Image, db, displayName, bio, newUsername, ethAddress);
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

  Future<Map> deleteUser(db) async {
    try {
      var data = await dbDeleteUser(db, ethAddress);
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

  Stream<dynamic> findAndWatchAllUsers(Db? db) {
    if (db != null) {
      return _useLookupStream(
        () => dbGetAllUsers(db),
        () => dbWatchAllUsers(db),
      );
    }
    return const Stream.empty();
  }

  Stream<T> _useLookupStream<T>(
    Future<T> Function() find,
    Stream<T> Function() watch, [
    List<Object?> keys = const <Object>[],
  ]) =>
      StreamGroup.mergeBroadcast([find().asStream(), watch()]);
}
