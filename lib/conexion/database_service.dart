import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late FirebaseFirestore _firestore;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<bool> connect() async {
    try {
      await Firebase.initializeApp(); // Initialize Firebase
      _firestore = FirebaseFirestore.instance;
      print('Conexión a Firestore establecida correctamente');
      return true;
    } catch (e) {
      print('Error al conectar a Firestore: $e');
      return false;
    }
  }

  FirebaseFirestore get firestore => _firestore;
}
