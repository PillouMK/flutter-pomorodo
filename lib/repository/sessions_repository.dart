import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class SessionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour récupérer toutes les sessions
  Future<List<Map<String, dynamic>>> getAllSessionsByUserID() async {
    try {
      CollectionReference sessions = _firestore.collection('sessions');
      final userID = FirebaseAuth.instance.currentUser?.uid;
      QuerySnapshot querySnapshot = await sessions.where('userUUID', isEqualTo: userID).get();

      return querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des sessions : $e");
      return [];
    }
  }

  // Méthode pour récupérer une session par ID
  Future<Map<String, dynamic>?> getSessionById(String sessionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('sessions').doc(sessionId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Erreur lors de la récupération de la session : $e");
      return null;
    }
  }

  Future<void> addSession({
    required DateTime date,
    required int sessionCount,
    required int workDuration,
  }) async {
    try {
      final userID = FirebaseAuth.instance.currentUser?.uid;
      final uuid = const Uuid().v4(); // Génère un UUID pour la session
      await _firestore.collection('sessions').doc(uuid).set({
        'uuid': uuid,
        'userUUID': userID,
        'date': date,
        'sessionCount': sessionCount,
        'workDuration': workDuration,
      });
      print("Session ajoutée avec succès !");
    } catch (e) {
      print("Erreur lors de l'ajout de la session : $e");
    }
  }
}