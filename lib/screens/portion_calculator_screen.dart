import 'package:flutter/material.dart';

class PortionCalculatorScreen extends StatefulWidget {
  const PortionCalculatorScreen({super.key});

  @override
  State<PortionCalculatorScreen> createState() => _PortionCalculatorScreenState();
}

class _PortionCalculatorScreenState extends State<PortionCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originalServingsController = TextEditingController();
  final _desiredServingsController = TextEditingController();
  final _ingredientsController = TextEditingController();
  List<String> _ingredients = [];
  List<String> _calculatedIngredients = [];

  @override
  void dispose() {
    _originalServingsController.dispose();
    _desiredServingsController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final ingredient = _ingredientsController.text.trim();
    if (ingredient.isNotEmpty) {
      setState(() {
        _ingredients.add(ingredient);
        _ingredientsController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _calculatePortions() {
    if (_formKey.currentState!.validate()) {
      final originalServings = double.parse(_originalServingsController.text);
      final desiredServings = double.parse(_desiredServingsController.text);
      final multiplier = desiredServings / originalServings;

      setState(() {
        _calculatedIngredients = _ingredients.map((ingredient) {
          // Try to extract quantity and unit from ingredient
          final parts = ingredient.split(' ');
          if (parts.length >= 2) {
            try {
              final quantity = double.parse(parts[0]);
              final unit = parts[1];
              final rest = parts.sublist(2).join(' ');
              final newQuantity = (quantity * multiplier).toStringAsFixed(2);
              return '$newQuantity $unit $rest';
            } catch (e) {
              // If parsing fails, return the original ingredient
              return ingredient;
            }
          }
          return ingredient;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Porsiya Kalkulyatoru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Servings Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Porsiya Ölçüsü',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _originalServingsController,
                              decoration: const InputDecoration(
                                labelText: 'Orijinal porsiya',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Zəhmət olmasa daxil edin';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Düzgün rəqəm daxil edin';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _desiredServingsController,
                              decoration: const InputDecoration(
                                labelText: 'İstənilən porsiya',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Zəhmət olmasa daxil edin';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Düzgün rəqəm daxil edin';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Ingredients Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İngredientlər',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ingredientsController,
                              decoration: const InputDecoration(
                                labelText: 'İngredient əlavə edin',
                                border: OutlineInputBorder(),
                                hintText: 'Məsələn: 2 stəkan un',
                              ),
                              onFieldSubmitted: (_) => _addIngredient(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _addIngredient,
                            icon: const Icon(Icons.add_circle),
                            color: Theme.of(context).colorScheme.primary,
                            iconSize: 32,
                          ),
                        ],
                      ),
                      if (_ingredients.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _ingredients.asMap().entries.map((entry) {
                            final index = entry.key;
                            final ingredient = entry.value;
                            return Chip(
                              label: Text(ingredient),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeIngredient(index),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primaryContainer,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Calculate Button
              ElevatedButton.icon(
                onPressed: _calculatePortions,
                icon: const Icon(Icons.calculate),
                label: const Text('Hesabla'),
              ),
              const SizedBox(height: 24),

              // Results
              if (_calculatedIngredients.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hesablanmış İngredientlər',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ..._calculatedIngredients.map((ingredient) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(ingredient)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 