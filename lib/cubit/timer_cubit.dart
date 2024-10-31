import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pomodoro/main.dart';
import '../model/timer.class.dart';
import 'package:timezone/timezone.dart' as tz;



class TimerCubit extends Cubit<TimerState?> {
  TimerCubit._() : super(null);

  static final instance = TimerCubit._();

  void setTimerCubit({required int workMinutes, required int restMinutes}) {
    emit(TimerState.start(workMinutes: workMinutes, restMinutes: restMinutes));
  }

  void setPause() {
    emit(state?.paused());
    flutterLocalNotificationsPlugin.cancelAll();
  }

  void setResume() {
    emit(state?.resumed());
    if (state != null) {
      TimerState currentState = state!;
      int nextStepIn = state!.nextStepIn.inSeconds;
      for (var i = 0; i < 30; i++) {
        tz.TZDateTime scheduledTimeBreak = tz.TZDateTime.now(tz.local).add(Duration(seconds: currentState.working
                ? nextStepIn + Duration(seconds: currentState.restMinutes).inSeconds
                : nextStepIn));

        scheduleNotification(i,"Pomodoro Timer",
          "Session de travail terminée ! C'est l'heure de la pause.",
          scheduledTimeBreak);

        tz.TZDateTime scheduledTimeWork = tz.TZDateTime.now(tz.local).add(Duration(seconds: currentState.working
                ? nextStepIn + Duration(seconds: currentState.workMinutes).inSeconds
                : nextStepIn));

        scheduleNotification(i+1,"Pomodoro Timer",
          "Pause terminée ! Il est temps de retourner au travail.",
          scheduledTimeWork);

        nextStepIn = nextStepIn + currentState.workMinutes + currentState.restMinutes;
      }
    }
  }

  void setStop() {
    emit(TimerState.start(workMinutes: state!.workMinutes, restMinutes: state!.restMinutes));
    setPause();
  }

  Future<void> scheduleNotification(int id, String title, String body, tz.TZDateTime scheduledTime) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id, // ID de notification (à incrémenter si plusieurs notifs en parallèle)
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro-timer', // Assure-toi que l'ID du channel est bien défini
          'Pomodoro Timer',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

}