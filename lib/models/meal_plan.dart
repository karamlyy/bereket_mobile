import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlan {
  final String userId;
  final Map<String, Map<String, String>> plan;
  final DateTime createdAt;
  final DateTime updatedAt;

  MealPlan({
    required this.userId,
    required this.plan,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'plan': plan,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    // Convert the nested map structure
    final Map<String, Map<String, String>> convertedPlan = {};
    final planMap = map['plan'] as Map<String, dynamic>;
    
    planMap.forEach((day, mealMap) {
      final mealTypeMap = mealMap as Map<String, dynamic>;
      convertedPlan[day] = {};
      mealTypeMap.forEach((mealType, recipeId) {
        convertedPlan[day]![mealType] = recipeId as String;
      });
    });

    return MealPlan(
      userId: map['userId'] as String,
      plan: convertedPlan,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
} 