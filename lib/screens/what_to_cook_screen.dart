import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class WhatToCookScreen extends StatefulWidget {
  const WhatToCookScreen({super.key});

  @override
  State<WhatToCookScreen> createState() => _WhatToCookScreenState();
}

class _WhatToCookScreenState extends State<WhatToCookScreen> {
  final _ingredientController = TextEditingController();
  final List<String> _ingredients = [];
  final GeminiService _geminiService = GeminiService();
  String? _aiSuggestion;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty) {
      setState(() {
        _ingredients.add(ingredient);
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _clearIngredients() {
    setState(() {
      _ingredients.clear();
      _aiSuggestion = null;
      _error = null;
    });
  }

  Future<void> _getRecipeSuggestions() async {
    if (_ingredients.isEmpty) {
      setState(() {
        _error = 'Zəhmət olmasa ən azı bir ingredient əlavə edin';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _aiSuggestion = null;
    });

    try {
      final suggestion = await _geminiService.getRecipeSuggestions(_ingredients);
      setState(() {
        _aiSuggestion = suggestion;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Resept hazırlanır...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormattedSuggestion(String suggestion) {
    final sections = suggestion.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) {
        if (section.trim().isEmpty) return const SizedBox(height: 8);
        
        if (section.startsWith('Başlıq:')) {
          return Text(
            section.replaceFirst('Başlıq:', '').trim(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          );
        } else if (section.startsWith('Təsvir:')) {
          return Text(
            section.replaceFirst('Təsvir:', '').trim(),
            style: Theme.of(context).textTheme.bodyLarge,
          );
        } else if (section.startsWith('Lazım olan maddələr:')) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lazım olan maddələr',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...section
                  .replaceFirst('Lazım olan maddələr:', '')
                  .trim()
                  .split(',')
                  .map((ingredient) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(ingredient.trim())),
                          ],
                        ),
                      )),
            ],
          );
        } else if (section.startsWith('Hazırlanması:')) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hazırlanması',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...section
                  .replaceFirst('Hazırlanması:', '')
                  .trim()
                  .split('.')
                  .where((step) => step.trim().isNotEmpty)
                  .map((step) => Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '•',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(step.trim())),
                          ],
                        ),
                      )),
            ],
          );
        } else if (section.startsWith('Bişirmə müddəti:') ||
            section.startsWith('Çətinlik:')) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  section.startsWith('Bişirmə müddəti:')
                      ? Icons.timer
                      : Icons.speed,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(section.trim()),
              ],
            ),
          );
        }
        return Text(section.trim());
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: const Text('Nə Bişirək?'),
            actions: [
              if (_ingredients.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _clearIngredients,
                  tooltip: 'Bütün ingredientləri təmizlə',
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Ingredients Input Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'İngredientlərinizi daxil edin',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ingredientController,
                              decoration: InputDecoration(
                                hintText: 'İngredient əlavə edin...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.mic),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Səs girişi tezliklə!'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              onSubmitted: (_) => _addIngredient(),
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
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            //onPressed:  _isLoading ? null : _getRecipeSuggestions,
                            // onPressed: () async {
                            //   await FirebaseAnalytics.instance.logEvent(
                            //     name: "recipe_ai_suggestion",
                            //     parameters: {
                            //       "ingredients": _ingredients.join(', '),
                            //     },
                            //   );
                            //   _isLoading ? null : _getRecipeSuggestions;
                            // },
                            onPressed: () async {
                              await FirebaseAnalytics.instance.logEvent(
                                name: "recipe_ai_suggestion",
                                parameters: {
                                  "ingredients": _ingredients.join(', '),
                                },
                              );
                              _getRecipeSuggestions();
                            },
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: Text(_isLoading
                                ? 'Təkliflər alınır...'
                                : 'Resept təklifləri al'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Suggestion Section
              if (_aiSuggestion != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AI Resept Təklifi',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.bookmark_border),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Resept seçilmişlərə əlavə edildi!'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFormattedSuggestion(_aiSuggestion!),
                      ],
                    ),
                  ),
                ),

              // Error Message
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Quick Suggestions Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sürətli Təkliflər',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSuggestionTile(
                        context,
                        'Sürətli & Asan',
                        '30 dəqiqə və ya daha az',
                        Icons.timer,
                        onTap: () {
                          // TODO: Implement quick recipes
                        },
                      ),
                      const Divider(),
                      _buildSuggestionTile(
                        context,
                        'Sağlam Seçimlər',
                        'Aşağı kalorili, yüksək qida dəyəri',
                        Icons.favorite,
                        onTap: () {
                          // TODO: Implement healthy recipes
                        },
                      ),
                      const Divider(),
                      _buildSuggestionTile(
                        context,
                        'Büdcə Dostu',
                        'Sərfəli ingredientlər',
                        Icons.attach_money,
                        onTap: () {
                          // TODO: Implement budget recipes
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildSuggestionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 