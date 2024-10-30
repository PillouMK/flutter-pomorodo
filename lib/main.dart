import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pomodoro/pages/timer.page.dart';

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
  final AuthService _authService = AuthService();

  void setTimerCubit(int workMinutes, int restMinutes) {
    TimerCubit.instance.setTimerCubit(workMinutes: workMinutes, restMinutes: restMinutes);
  }

  Future<List<Map<String, dynamic>>> fetchAllSessions() async {
    try {
      // Récupère la collection "session" depuis Firestore
      CollectionReference sessions = FirebaseFirestore.instance.collection('sessions');

      // Récupère les documents de la collection
      QuerySnapshot querySnapshot = await sessions.get();

      // Transforme les documents en une liste de maps
      List<Map<String, dynamic>> sessionsData = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
      print('cc');
      print(sessionsData);

      return sessionsData;
    } catch (e) {
      print("Erreur lors de la récupération des sessions : $e");
      return [];
    }
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
            }, child: const Text("2/1")),
            ElevatedButton(
              onPressed: () async {
                User? user = await _authService.signInWithGoogle();
                if (user != null) {
                  // Si la connexion réussit, vous pouvez naviguer vers une nouvelle page
                  print("user logged");
                  print(user.uid);
                } else {
                  print("fail during login");
                }
              },
              child: Text('Se connecter avec Google'),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchAllSessions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune session trouvée.'));
                }

                // Affiche la liste des sessions
                List<Map<String, dynamic>> sessions = snapshot.data!;
                return Container(
                  child: Text('data'),
                );
              },
            )
          ],
        )
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
