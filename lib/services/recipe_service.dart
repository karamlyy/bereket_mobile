import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'recipes';

  Future<List<Recipe>> getRecipes() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Recipe.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recipes: $e');
    }
  }

  Stream<List<Recipe>> streamRecipes() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Recipe.fromMap({...doc.data(), 'id': doc.id}))
        .toList());
  }
}