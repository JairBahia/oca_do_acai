import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream em tempo real de todos os produtos ordenados por categoria.
  Stream<List<Product>> cardapioStream() {
    return _db
        .collection('cardapio')
        .orderBy('category')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList());
  }

  /// Salva um pedido na coleção 'pedidos' do Firestore.
  Future<void> salvarPedido({
    required List<Map<String, dynamic>> itens,
    required double total,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    await _db.collection('pedidos').add({
      'userId': user?.uid ?? 'anonimo',
      'userEmail': user?.email ?? 'anonimo',
      'itens': itens,
      'total': total,
      'status': 'recebido',
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }
}