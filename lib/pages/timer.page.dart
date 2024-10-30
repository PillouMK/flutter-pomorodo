
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void resetTimer() {
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
