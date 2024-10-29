import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pomodoro/pages/timer.page.dart';

import 'cubit/timer_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: TimerCubit.instance,
      child: MaterialApp(
        title: 'Pomodoro Timer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Pomodoro Timer'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void setTimerCubit(int workMinutes, int restMinutes) {
    TimerCubit.instance.setTimerCubit(workMinutes: workMinutes, restMinutes: restMinutes);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
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
            }, child: const Text("2/1"))
          ],
        )
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
