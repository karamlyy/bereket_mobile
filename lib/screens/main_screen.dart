import 'package:flutter/material.dart';
import 'package:task_manager/screens/recipe_home_screen.dart';
import 'profile_screen.dart';
import 'recipes_screen.dart';
import 'what_to_cook_screen.dart';
import 'meal_planner_screen.dart';
import 'portion_calculator_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const RecipeListScreen(),
    const WhatToCookScreen(),
    const MealPlannerScreen(),
    const PortionCalculatorScreen(),
    const RecipeHomeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Əsas',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            label: 'Nə bişirək',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Yemək planı',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate),
            label: 'Kalkulyator',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_restaurant),
            label: 'Reseptlər',
          ),

        ],
      ),
    );
  }
} 