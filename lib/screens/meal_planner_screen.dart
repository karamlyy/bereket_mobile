import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe.dart';
import '../services/meal_plan_service.dart';
import '../services/auth_service.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final MealPlanService _mealPlanService = MealPlanService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  final List<String> _weekDays = [
    'Bazar ertəsi',
    'Çərşənbə axşamı',
    'Çərşənbə',
    'Cümə axşamı',
    'Cümə',
    'Şənbə',
    'Bazar',
  ];

  final List<String> _mealTypes = [
    'Səhər yeməyi',
    'Nahar',
    'Axşam yeməyi',
  ];

  Map<String, Map<String, Recipe?>> _mealPlan = {};

  @override
  void initState() {
    super.initState();
    _initializeMealPlan();
  }

  Future<void> _initializeMealPlan() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize meal plan with empty values
    for (var day in _weekDays) {
      _mealPlan[day] = {};
      for (var meal in _mealTypes) {
        _mealPlan[day]![meal] = null;
      }
    }

    // Load saved meal plan from Firebase
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      final savedPlan = await _mealPlanService.getMealPlan(userId);
      if (savedPlan != null) {
        final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
        for (var day in _weekDays) {
          for (var meal in _mealTypes) {
            final recipeId = savedPlan.plan[day]?[meal];
            if (recipeId != null) {
              final recipe = recipeProvider.recipes.firstWhere(
                (r) => r.id == recipeId,
                orElse: () => Recipe(
                  id: '',
                  title: '',
                  description: '',
                  category: '',
                  imageUrl: '',
                  cookingTime: 0,
                  servings: 0,
                  ingredients: [],
                  instructions: [],
                  isFavorite: false,
                  difficulty: Difficulty.Easy,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
              if (recipe.id.isNotEmpty) {
                _mealPlan[day]![meal] = recipe;
              }
            }
          }
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveMealPlan() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    // Convert Recipe objects to recipe IDs
    final Map<String, Map<String, String>> planToSave = {};
    for (var day in _weekDays) {
      planToSave[day] = {};
      for (var meal in _mealTypes) {
        final recipe = _mealPlan[day]![meal];
        planToSave[day]![meal] = recipe?.id ?? '';
      }
    }

    await _mealPlanService.saveMealPlan(userId, planToSave);
  }

  void _showRecipeSelector(String day, String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Consumer<RecipeProvider>(
            builder: (context, recipeProvider, child) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Resept seçin',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: recipeProvider.recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipeProvider.recipes[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              recipe.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          title: Text(recipe.title),
                          subtitle: Text(
                            '${recipe.cookingTime} dəqiqə • ${recipe.servings} nəfərlik',
                          ),
                          onTap: () async {
                            setState(() {
                              _mealPlan[day]![mealType] = recipe;
                            });
                            await _saveMealPlan();
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _generateShoppingList() {
    // Collect all ingredients from the meal plan
    final Set<String> ingredients = {};
    for (var day in _weekDays) {
      for (var meal in _mealTypes) {
        final recipe = _mealPlan[day]![meal];
        if (recipe != null) {
          ingredients.addAll(recipe.ingredients);
        }
      }
    }

    // Show shopping list in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alış-veriş siyahısı'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: Text(ingredients.elementAt(index)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bağla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Paylaş'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Həftəlik Yemək Planı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _generateShoppingList,
            tooltip: 'Alış-veriş siyahısı',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _weekDays.length,
              itemBuilder: (context, dayIndex) {
                final day = _weekDays[dayIndex];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          day,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      ..._mealTypes.map((mealType) {
                        final recipe = _mealPlan[day]![mealType];
                        return ListTile(
                          title: Text(mealType),
                          subtitle: recipe != null
                              ? Text(recipe.title)
                              : const Text('Resept seçilməyib'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (recipe != null)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    setState(() {
                                      _mealPlan[day]![mealType] = null;
                                    });
                                    await _saveMealPlan();
                                  },
                                  tooltip: 'Resepti sil',
                                ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () => _showRecipeSelector(day, mealType),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
    );
  }
} 