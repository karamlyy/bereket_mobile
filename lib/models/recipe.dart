import 'package:cloud_firestore/cloud_firestore.dart';

enum Difficulty {
  Easy,
  Medium,
  Hard,
}

enum DietType {
  Regular,
  Vegetarian,
  Vegan,
  Keto,
  Halal,
  GlutenFree,
}

class Recipe {
  final String id;
  final String title;
  final String description;
  final String category;
  final int cookingTime;
  final int servings;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final bool isFavorite;
  final Difficulty difficulty;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DietType diet;
  final int calories;
  final int protein;
  final int fat;
  final int carbohydrates;
  final bool isHealthy;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.cookingTime,
    required this.servings,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.isFavorite,
    required this.difficulty,
    required this.createdAt,
    required this.updatedAt,
    this.diet = DietType.Regular,
    this.calories = 0,
    this.protein = 0,
    this.fat = 0,
    this.carbohydrates = 0,
    this.isHealthy = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'cookingTime': cookingTime,
      'servings': servings,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'isFavorite': isFavorite,
      'difficulty': difficulty.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'diet': diet.toString().split('.').last,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
      'isHealthy': isHealthy,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      cookingTime: map['cookingTime'] as int,
      servings: map['servings'] as int,
      imageUrl: map['imageUrl'] as String,
      ingredients: List<String>.from(map['ingredients'] as List),
      instructions: List<String>.from(map['instructions'] as List),
      isFavorite: map['isFavorite'] ?? false,
      difficulty: Difficulty.values.firstWhere(
            (e) => e.toString().split('.').last == map['difficulty'],
        orElse: () => Difficulty.Medium,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      diet: DietType.values.firstWhere(
        (e) => e.toString().split('.').last == map['diet'],
        orElse: () => DietType.Regular,
      ),
      calories: map['calories'] ?? 0,
      protein: map['protein'] ?? 0,
      fat: map['fat'] ?? 0,
      carbohydrates: map['carbohydrates'] ?? 0,
      isHealthy: map['isHealthy'] ?? false,
    );
  }
}