import 'package:Beepo/app.dart';

import 'package:Beepo/services/database.dart';
import 'package:Beepo/session/foreground_session.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:xmtp/xmtp.dart';

class ChatProvider extends ChangeNotifier {
  List<DecodedMessage>? messages;
  List<Conversation>? convos;
  dynamic statuses = Hive.box('Beepo2.0').get('Statuses');
  String? me;

  getAllStatus(db) {
    var d = dbGetAllStatus(db);
    return d;
  }

  Future<String> uploadStatus(
      base64Image, db, text, privacy, ethAddress) async {
    try {
      await dbUploadStatus(base64Image, db, text, privacy, ethAddress);
      saveStatuses(db);
      return "done";
    } catch (e) {
      if (kDebugMode) {
        beepoPrint(e);
        return (e.toString());
      }
    }
    return ('Not done');
  }

  Future<String> deleteStatus(db, List data, ethAddress) async {
    try {
      await dbDeleteStatus(db, data, ethAddress);
      saveStatuses(db);
      return "done";
    } catch (e) {
      if (kDebugMode) {
        beepoPrint(e);
        return (e.toString());
      }
    }
    return ('Not done');
  }

  void saveStatuses(db) async {
    var event = await dbGetAllStatus(db);
    beepoPrint(event);
    try {
      var data = event.map((e) {
        return {
          "data": e['data'],
          "ethAddress": e['ethAddress'],
          "viewers": e['viewers'],
        };
      });

      await Hive.box('Beepo2.0').put('Statuses', data.toList());
      statuses = data.toList();
      notifyListeners();

      beepoPrint(statuses.last['data'].last);
      beepoPrint(data.last['data'].last);
    } catch (e) {
      debugPrint(" chat ln 52 ${e.toString()}");
    }
  }

  void updateMessages(List<DecodedMessage> event) async {
    // beepoPrint(event.length);
    if (event.isEmpty) return;
    if (messages != null && messages!.isNotEmpty) {
      if (messages![0].sentAt == event[0].sentAt &&
          messages![0].sender == event[0].sender) {
        messages = event;
        notifyListeners();
        return;
      }
      if (event[0].sender.toString() == me) {
        messages = event;
        notifyListeners();
        return;
      }
      sendNotification(event[0]);
    }
    messages = event;
    notifyListeners();
  }

  void updateConvos(List<Conversation> event) async {
    if (event.isEmpty) return;
    me = me ?? event[0].me.toString();
    convos = event;
    notifyListeners();
  }

  Stream<dynamic> findAndWatchAllStatuses(FirebaseFirestore db) {
    if (db != null) {
      beepoPrint('hiiiii   2');
      return _useLookupStream(
        () => dbGetAllStatus(db),
        () => dbWatchAllStatus(db),
      );
    }
    return const Stream.empty();
  }

  Stream<List<Conversation>> findAndWatchAllConvos() {
    return _useLookupStream(
      () => session.findConversations(),
      () => session.watchConversations(),
    );
  }

  Stream<List<DecodedMessage>> findAndWatchAllMessages() {
    return _useLookupStream(
      () => session.findAllMessages(),
      () => session.watchAllMessages(),
    );
  }

  Stream<T> _useLookupStream<T>(
    Future<T> Function() find,
    Stream<T> Function() watch, [
    List<Object?> keys = const <Object>[],
  ]) =>
      StreamGroup.mergeBroadcast([find().asStream(), watch()]);
}
