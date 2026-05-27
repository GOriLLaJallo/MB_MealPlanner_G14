import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'recipes_screen.dart';
import 'pantry_screen.dart';
import 'meal_plan_screen.dart';
import 'shopping_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    RecipesScreen(),
    PantryScreen(),
    MealPlanScreen(),
    ShoppingListScreen(),
  ];

  final List<_NavDestination> _destinations = const [
    _NavDestination(label: 'Home', icon: Icons.dashboard_rounded),
    _NavDestination(label: 'Ricette', icon: Icons.menu_book_rounded),
    _NavDestination(label: 'Dispensa', icon: Icons.kitchen_rounded),
    _NavDestination(label: 'Pasti', icon: Icons.calendar_month_rounded),
    _NavDestination(label: 'Spesa', icon: Icons.shopping_cart_rounded),
  ];

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                _DesktopSideNavigation(
                  currentIndex: _currentIndex,
                  destinations: _destinations,
                  onTap: _changePage,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: KeyedSubtree(
                      key: ValueKey(_currentIndex),
                      child: _screens[_currentIndex],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                bottom: 98,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(_currentIndex),
                    child: _screens[_currentIndex],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: SafeArea(
                  top: false,
                  child: _MobileFloatingNavigation(
                    currentIndex: _currentIndex,
                    destinations: _destinations,
                    onTap: _changePage,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavDestination {
  final String label;
  final IconData icon;

  const _NavDestination({required this.label, required this.icon});
}

class _MobileFloatingNavigation extends StatelessWidget {
  final int currentIndex;
  final List<_NavDestination> destinations;
  final ValueChanged<int> onTap;

  const _MobileFloatingNavigation({
    required this.currentIndex,
    required this.destinations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(destinations.length, (index) {
          final item = destinations[index];
          final selected = index == currentIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: selected ? 66 : 54,
              height: selected ? 66 : 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? colorScheme.primary : const Color(0xFFF1F3F6),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.32),
                          blurRadius: 15,
                          offset: const Offset(0, 7),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    color: selected ? Colors.white : Colors.grey.shade600,
                    size: selected ? 27 : 24,
                  ),
                  if (selected) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DesktopSideNavigation extends StatelessWidget {
  final int currentIndex;
  final List<_NavDestination> destinations;
  final ValueChanged<int> onTap;

  const _DesktopSideNavigation({
    required this.currentIndex,
    required this.destinations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        width: 112,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white,
                size: 29,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(destinations.length, (index) {
                  final item = destinations[index];
                  final selected = index == currentIndex;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => onTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 78,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? colorScheme.primary.withOpacity(0.11)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? colorScheme.primary
                                    : const Color(0xFFF1F3F6),
                              ),
                              child: Icon(
                                item.icon,
                                color: selected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: selected
                                    ? colorScheme.primary
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
