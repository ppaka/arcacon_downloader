import 'package:arcacon_downloader/screen/first_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> progressNotification(
    String conTitle, int nowProgress, int maxProgress) async {
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('Task Notifications ID', 'Task Notifications',
          importance: Importance.low,
          priority: Priority.low,
          channelAction: AndroidNotificationChannelAction.createIfNotExists,
          onlyAlertOnce: false,
          enableVibration: false,
          channelShowBadge: false,
          icon: 'ic_stat_name',
          playSound: false,
          setAsGroupSummary: false,
          autoCancel: false,
          showProgress: true,
          maxProgress: maxProgress,
          progress: nowProgress,
          ongoing: true);
  final NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(nowRunning[conTitle]!,
      '아카콘 다운로드 중...', conTitle, platformChannelSpecifics,
      payload: 'item x');
}

Future<void> showNotification(String conTitle) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'Ended Task Notifications ID', 'Ended Task Notifications',
          channelShowBadge: true,
          importance: Importance.high,
          priority: Priority.high,
          onlyAlertOnce: false,
          icon: 'ic_stat_name',
          setAsGroupSummary: false);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(nowRunning[conTitle]!.hashCode,
      '아카콘 다운로드 완료!', conTitle, platformChannelSpecifics,
      payload: 'item x');
}
