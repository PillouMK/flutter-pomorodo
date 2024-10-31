
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pomodoro/repository/sessions_repository.dart';
import 'package:flutter_pomodoro/widgets/pomodoro.dart';

import '../cubit/timer_cubit.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {


  // void resetTimer() {
  //   TimerCubit.instance.state!.resumed();
  // }

  // void resetTimer() {
  //   final currentState = TimerCubit.instance.state!;
  
  //   if (currentState.timeElapsed.inSeconds > 0) {
  //     final sessionRepository = SessionRepository();
  //     sessionRepository.addSession(
  //       date: currentState.startedAt,
  //       sessionCount: currentState.sessionCount,
  //       workDuration: currentState.totalWorkDuration + (currentState.working ? currentState.timeElapsed.inSeconds : 0),
  //     );
  //   }

  //   TimerCubit.instance.setStop();
  // }

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
