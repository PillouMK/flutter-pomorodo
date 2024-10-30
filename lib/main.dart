import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pomodoro/pages/archives_list.dart';
import 'package:flutter_pomodoro/pages/timer.page.dart';
import 'package:flutter_pomodoro/pages/timer_list.dart';
import 'package:flutter_pomodoro/repository/sessions_repository.dart';

import 'authentification/auth_service.dart';
import 'cubit/timer_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
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
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  User? _user;

  final List<Widget> _pages = [
    const TimerList(),
    const ArchivesList(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _checkUser() {
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> _signInWithGoogle() async {
    User? user = await _authService.signInWithGoogle();
    if (user != null) {
      _checkUser();
    }
  }

  Future<void> _signOut() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text("Voulez-vous vraiment vous déconnecter ?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Déconnexion"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _authService.signOut();
      _checkUser();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(_user == null ? Icons.login : Icons.logout),
            onPressed: _user == null ? _signInWithGoogle : _signOut,
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Affiche la page en fonction de l'index sélectionné
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.timer), // Icône pour la page TimerList
            label: 'Timers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive), // Icône pour la page ArchiveList
            label: 'Archives',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
