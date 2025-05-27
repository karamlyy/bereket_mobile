import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_plan.dart';

class MealPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'meal_plans';

  Future<void> saveMealPlan(String userId, Map<String, Map<String, String>> plan) async {
    final now = DateTime.now();
    final mealPlan = MealPlan(
      userId: userId,
      plan: plan,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore
        .collection(_collection)
        .doc(userId)
        .set(mealPlan.toMap());
  }

  Future<MealPlan?> getMealPlan(String userId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(userId)
        .get();

    if (doc.exists) {
      return MealPlan.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateMealPlan(String userId, Map<String, Map<String, String>> plan) async {
    final now = DateTime.now();
    final mealPlan = MealPlan(
      userId: userId,
      plan: plan,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore
        .collection(_collection)
        .doc(userId)
        .update(mealPlan.toMap());
  }

  Future<void> deleteMealPlan(String userId) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .delete();
  }
} 