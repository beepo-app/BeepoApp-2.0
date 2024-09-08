import 'dart:convert';
import 'dart:io';

import 'package:Beepo/screens/messaging/chats/chat_dm_screen.dart';
import 'package:Beepo/session/foreground_session.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:Beepo/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
// import 'package:get/get_navigation/get_navigation.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'ChatChannel',
          channelName: 'Chat Channel',
          channelDescription: 'Chat Messages Channed',
          defaultColor: AppColors.primaryColor,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          criticalAlerts: true,
          onlyAlertOnce: true,
          icon: null,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'ChatChannelGroup',
            channelGroupName: 'Chat Group 1'),
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    );
  }

  static Future<void> onActionReceivedMethod(received) async {
    debugPrint('onreceid no');
    beepoPrint(received);
    final payload = received.payload ?? {};
    if (received.buttonKeyInput.length > 0) {
      session
          .sendMessage(payload['topic'], received.buttonKeyInput)
          .whenComplete(() => AwesomeNotifications().cancel(received.id));
      return;
    }
    if (payload['navigate'] == 'true') {
      if (payload['destination'] == "Wallet") {
        return;
      }
      Get.to(() => ChatDmScreen(
            topic: payload['topic']!,
            userData: jsonDecode(payload['userData']!),
            senderAddress: payload['sender'],
          ));
    }
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedNotification received) async {
    debugPrint('on dismissed no');
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification received) async {
    debugPrint('on createdon  no');
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification received) async {
    debugPrint('on display no');
  }

  static Future<void> showNotifications({
    required final String title,
    required final String body,
    final String? summary,
    final String? img,
    final String? imgText,
    final Map<String, String>? payload,
    final NotificationLayout notificationLayout = NotificationLayout.Messaging,
  }) async {
    File? file;

    if (img != null) {
      Uint8List bytes = base64Decode(img);
      final appDir = await syspaths.getTemporaryDirectory();
      file = File('${appDir.path}/sth.jpg');
      await file.writeAsBytes(bytes);
    }

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: -1,
          channelKey: 'ChatChannel',
          title: title,
          body: body,
          largeIcon: img != null ? "file://${file!.path}" : null,
          roundedLargeIcon: true,
          summary: summary,
          payload: payload,
          notificationLayout: notificationLayout,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'key',
            label: 'Reply',
            requireInputText: true,
            autoDismissible: true,
            actionType: ActionType.KeepOnTop,
          ),
        ]);
  }
}
