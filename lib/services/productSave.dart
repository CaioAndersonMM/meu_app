import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> salvarProduto(String userId, String productId) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    await userDoc.set({
      'favoriteProducts': FieldValue.arrayUnion([productId]),
    }, SetOptions(merge: true));
  }

  Future<void> apagarProduto(String userId, String productId) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    await userDoc.set({
      'favoriteProducts': FieldValue.arrayRemove([productId]),
    }, SetOptions(merge: true));
  }


  Future<List<String>> obterProdutosFavoritados(String userId) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    DocumentSnapshot snapshot = await userDoc.get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      List<String> favoriteProducts = List<String>.from(data?['favoriteProducts'] ?? []);
      return favoriteProducts;
    }
    return [];
  }

}
