import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/timer_cubit.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  late Timer _timer;

  String formatTime(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }

  void startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    startAutoRefresh();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerCubit>().state;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          height: 200,
          width: 200,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
                color: Colors.cyan
          ),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                value: timer!.timeLeft.inMilliseconds / timer.duration.inMilliseconds,
              ),
              Center(
                child: Text(
                  formatTime(timer.timeLeft),
                  style: const TextStyle(fontSize: 48, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
