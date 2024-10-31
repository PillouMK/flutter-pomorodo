
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pomodoro/main.dart';
import 'package:flutter_pomodoro/repository/sessions_repository.dart';
import 'package:flutter_pomodoro/widgets/pomodoro.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../cubit/timer_cubit.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {

  void resetTimer() {
    final currentState = TimerCubit.instance.state!;

    if (currentState.timeElapsed.inSeconds > 0) {
      final sessionRepository = SessionRepository();
      
      // Calculez le nombre total de sessions de travail
      int sessionCount = 0;
      int workDuration = 0;

      int timeElapsed = currentState.timeElapsed.inSeconds;
      int workSeconds = currentState.workMinutes * 60;
      int restSeconds = currentState.restMinutes * 60;
      
      // Calculez le nombre de sessions complètes
      int totalCycleDuration = workSeconds + restSeconds; // Durée d'un cycle complet
      sessionCount = timeElapsed ~/ totalCycleDuration; // Nombre de cycles complets

      // Calculez la durée de travail pour les cycles complets
      workDuration = sessionCount * workSeconds;

      // Calculez le reste du temps
      int remainingTime = timeElapsed % totalCycleDuration;
      
      // Ajoutez le temps de travail partiel, si applicable
      if (remainingTime < workSeconds) {
        workDuration += remainingTime; // Temps de travail partiel
      } else {
        workDuration += workSeconds; // Temps de travail complet pour la session en cours
      }

      sessionCount ++;

      // Enregistrez la session dans Firestore
      sessionRepository.addSession(
        date: currentState.startedAt,
        sessionCount: sessionCount,
        workDuration: workDuration,
      );
    }

    TimerCubit.instance.setStop();
  }

  void pauseTimer() {
    if(TimerCubit.instance.state!.pausedAt != null) {
      TimerCubit.instance.setResume();
    } else {
      TimerCubit.instance.setPause();
    }
  }

  Future<void> scheduleNotification(int id, String title, String body, tz.TZDateTime scheduledTime) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro-timer',
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

  @override
  void initState() {
    super.initState();

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));

    final currentState = TimerCubit.instance.state!;
    final workSeconds = currentState.workMinutes * 60;
    final restSeconds = currentState.restMinutes * 60;

    int nextStepIn = currentState.nextStepIn.inMinutes;
    for (var i = 0; i < 30; i++) {
      tz.TZDateTime scheduledTimeBreak = tz.TZDateTime.now(tz.local).add(Duration(minutes: currentState.working
              ? nextStepIn + Duration(minutes: currentState.restMinutes).inMinutes
              : nextStepIn));

      scheduleNotification(i,"Pomodoro Timer",
        "Session de travail terminée ! C'est l'heure de la pause.",
        scheduledTimeBreak);

      tz.TZDateTime scheduledTimeWork = tz.TZDateTime.now(tz.local).add(Duration(minutes: currentState.working
              ? nextStepIn + Duration(minutes: currentState.workMinutes).inMinutes
              : nextStepIn));

      scheduleNotification(i+1,"Pomodoro Timer",
        "Pause terminée ! Il est temps de retourner au travail.",
        scheduledTimeWork);

      nextStepIn = nextStepIn + currentState.workMinutes + currentState.restMinutes;
    }
  }


  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerCubit>().state!;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Pomodoro Timer Page'),
    ), body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const PomodoroTimer(),
          const SizedBox(
            width: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: pauseTimer,
                child: Icon(
                  timer.isRunning ? Icons.pause : Icons.play_arrow,
                  color: Colors.pink,
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 20,),
              ElevatedButton(
                onPressed: resetTimer,
                child: const Icon(
                  Icons.stop,
                  color: Colors.pink,
                  size: 24.0,
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }
}
