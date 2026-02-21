import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum TimerControlAction {
  pause,
  resume,
  stop,
}

const String _timerActionPause = 'timer_pause';
const String _timerActionResume = 'timer_resume';
const String _timerActionStop = 'timer_stop';
const String _pendingTimerActionKey = 'pending_timer_action';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  final actionId = response.actionId;
  if (actionId == null || actionId.isEmpty) return;

  SharedPreferences.getInstance().then((prefs) {
    prefs.setString(_pendingTimerActionKey, actionId);
  });
}

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final StreamController<TimerControlAction> _timerActionController =
      StreamController<TimerControlAction>.broadcast();

  static const int _pomodoroAlertId = 9001;
  static const int _timerControlsId = 9002;

  Stream<TimerControlAction> get timerActions => _timerActionController.stream;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    await _requestPermissions();
  }

  Future<TimerControlAction?> consumePendingTimerAction() async {
    final prefs = await SharedPreferences.getInstance();
    final actionId = prefs.getString(_pendingTimerActionKey);
    if (actionId == null || actionId.isEmpty) return null;

    await prefs.remove(_pendingTimerActionKey);
    return _mapActionId(actionId);
  }

  void _onNotificationResponse(NotificationResponse response) {
    final action = _mapActionId(response.actionId);
    if (action != null) {
      _timerActionController.add(action);
    }
  }

  TimerControlAction? _mapActionId(String? actionId) {
    switch (actionId) {
      case _timerActionPause:
        return TimerControlAction.pause;
      case _timerActionResume:
        return TimerControlAction.resume;
      case _timerActionStop:
        return TimerControlAction.stop;
      default:
        return null;
    }
  }

  Future<void> _requestPermissions() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  Future<void> schedulePomodoroPhaseEnd({
    required int secondsFromNow,
    required String title,
    required String body,
  }) async {
    if (secondsFromNow <= 0) return;

    const androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Alerts',
      channelDescription: 'Pomodoro phase end notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    final scheduleTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: secondsFromNow));

    await _plugin.zonedSchedule(
      _pomodoroAlertId,
      title,
      body,
      scheduleTime,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );

    if (kDebugMode) {
      debugPrint('🔔 Pomodoro notification scheduled in ${secondsFromNow}s');
    }
  }

  Future<void> cancelPomodoroNotifications() async {
    await _plugin.cancel(_pomodoroAlertId);
  }

  Future<void> showAndroidTimerControls({
    required bool isRunning,
    required String elapsedLabel,
    String? category,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final subtitle = category == null || category.isEmpty
        ? '타이머를 제어하세요'
        : '$category · $elapsedLabel';

    final actions = <AndroidNotificationAction>[
      AndroidNotificationAction(
        isRunning ? _timerActionPause : _timerActionResume,
        isRunning ? '일시정지' : '재개',
        cancelNotification: false,
        showsUserInterface: false,
      ),
      const AndroidNotificationAction(
        _timerActionStop,
        '종료',
        cancelNotification: false,
        showsUserInterface: false,
      ),
    ];

    final androidDetails = AndroidNotificationDetails(
      'timer_controls_channel',
      'Timer Controls',
      channelDescription: '잠금화면에서 타이머를 제어합니다.',
      importance: Importance.max,
      priority: Priority.max,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.service,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: false,
      actions: actions,
    );

    await _plugin.show(
      _timerControlsId,
      '포모도로 타이머',
      subtitle,
      NotificationDetails(android: androidDetails),
      payload: 'timer_controls',
    );
  }

  Future<void> cancelAndroidTimerControls() async {
    await _plugin.cancel(_timerControlsId);
  }

  void dispose() {
    _timerActionController.close();
  }
}
