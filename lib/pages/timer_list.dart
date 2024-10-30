import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/pages/timer.page.dart';

import '../authentification/auth_service.dart';
import '../cubit/timer_cubit.dart';
import '../repository/sessions_repository.dart';

class TimerList extends StatefulWidget {
  const TimerList({super.key});

  @override
  State<TimerList> createState() => _TimerListState();
}

class _TimerListState extends State<TimerList> {
  final AuthService _authService = AuthService();

  void setTimerCubit(int workMinutes, int restMinutes) {
    TimerCubit.instance.setTimerCubit(workMinutes: workMinutes, restMinutes: restMinutes);
  }
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: () => {
              setTimerCubit(45, 15),
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimerPage()),
              )
            }, child: const Text("45/15")),
            ElevatedButton(onPressed: () => {
              setTimerCubit(25, 5),
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimerPage()),
              )
            }, child: const Text("25/5")),
            ElevatedButton(onPressed: () => {
              setTimerCubit(2, 1),
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimerPage()),
              )
            }, child: const Text("2/1")),
          ],
        )
    );
  }
}
