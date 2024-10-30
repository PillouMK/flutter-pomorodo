import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../authentification/auth_service.dart';
import '../repository/sessions_repository.dart';

class ArchivesList extends StatefulWidget {
  const ArchivesList({super.key});

  @override
  State<ArchivesList> createState() => _ArchivesListState();
}

class _ArchivesListState extends State<ArchivesList> {
  final SessionRepository sessionRepository = SessionRepository();
  final AuthService _authService = AuthService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkUser();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archives'),
      ),
      body: StreamBuilder<User?>(
        stream: _authService.user, // Écoute le stream d'authentification
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          // Vérifiez si l'utilisateur est connecté
          User? user = snapshot.data;
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Veuillez vous connecter pour voir l\'historique des sessions',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),

                ],
              ),
            );
          }

          // Si l'utilisateur est connecté, récupérez les sessions
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: sessionRepository.getAllSessionsByUserID(),
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
              return ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return ListTile(
                    title: Text('Session ${session['sessionCount']}'),
                    subtitle: Text('Durée : ${session['workDuration']} minutes'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}