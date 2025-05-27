import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedCookingTime = 'All';

  List<Recipe> get recipes => _recipes;
  List<Recipe> get filteredRecipes => _filteredRecipes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedCookingTime => _selectedCookingTime;

  List<String> get categories {
    final categories = _recipes.map((recipe) => recipe.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  List<String> get cookingTimeCategories => ['All', 'Tezbişən', 'Orta', 'Gecbişən'];

  Future<void> loadRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recipes = await _recipeService.getRecipes();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchRecipes(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setCookingTime(String cookingTime) {
    _selectedCookingTime = cookingTime;
    _applyFilters();
  }

  bool _matchesCookingTime(Recipe recipe) {
    switch (_selectedCookingTime) {
      case 'Tezbişən':
        return recipe.cookingTime < 30;
      case 'Orta':
        return recipe.cookingTime >= 30 && recipe.cookingTime <= 60;
      case 'Gecbişən':
        return recipe.cookingTime > 60;
      default:
        return true;
    }
  }

  void _applyFilters() {
    _filteredRecipes = _recipes.where((recipe) {
      final matchesSearch = _searchQuery.isEmpty ||
          recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          recipe.category == _selectedCategory;

      final matchesCookingTime = _matchesCookingTime(recipe);

      return matchesSearch && matchesCategory && matchesCookingTime;
    }).toList();

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}