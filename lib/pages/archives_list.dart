import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMMM yyyy à HH:mm').format(dateTime);
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
        title: const Text('Historique des sessions'),
      ),
      body: StreamBuilder<User?>(
        stream: _authService.user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

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

              List<Map<String, dynamic>> sessions = snapshot.data!;
              return ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Card(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Date : ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                formatTimestamp(session['date']),
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Text(
                              'Session(s) : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${session['sessionCount']}'),
                          ],),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Text(
                              'Durée : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${session['workDuration']} minutes'),
                          ],)
                        ],
                      ),
                    ),
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