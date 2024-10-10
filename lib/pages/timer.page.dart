import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/widgets/pomodoro.dart';

import '../cubit/timer_cubit.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {


  void resetTimer() {
    TimerCubit.instance.state!.resumed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Pomodoro Timer Page'),
    ), body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const PomodoroTimer(),
        const SizedBox(
          width: 20,
        ),
        ElevatedButton(
          onPressed: resetTimer,
          child: const Text('Reset Timer'),
        ),
      ],
    ));
  }
}
