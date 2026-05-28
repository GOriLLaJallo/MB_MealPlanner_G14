import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/app_provider.dart';
import '../utils/theme.dart';
import 'recipe_detail_screen.dart';
import 'statistics_screen.dart';
import 'recipes_screen.dart';
import 'meal_plan_screen.dart';
import 'pantry_screen.dart';
import '../models/recipe.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color _backgroundColor = Color(0xFFF5F7FB);
  static const Color _darkText = Color(0xFF1F2937);
  static const Color _mutedText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final expiringItems = provider.expiringPantryItems;
            final recipesCount = provider.recipes.length;

            final mealPlansCount = provider.mealPlans
                .where(
                  (m) =>
                      m.date.isAfter(
                        DateTime.now().subtract(const Duration(days: 1)),
                      ) &&
                      m.date.isBefore(
                        DateTime.now().add(const Duration(days: 7)),
                      ),
                )
                .length;

            final suggestable = provider.getSuggestableRecipes();

            final Map<String, int> categories = {};
            for (final recipe in provider.recipes) {
              categories[recipe.category] =
                  (categories[recipe.category] ?? 0) + 1;
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 850;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 32 : 16,
                    18,
                    isDesktop ? 32 : 16,
                    isDesktop ? 32 : 28,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(context),
                          const SizedBox(height: 18),
                          _buildHeroSection(
                            context: context,
                            recipes: provider.getSuggestableRecipes(),
                          ),
                          const SizedBox(height: 18),
                          _buildStatsGrid(
                            context: context,
                            recipesCount: recipesCount,
                            mealPlansCount: mealPlansCount,
                            expiringCount: expiringItems.length,
                            suggestableCount: suggestable.length,
                          ),
                          const SizedBox(height: 18),
                          _buildChartCard(context, categories),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SmartMeal',
                style: TextStyle(
                  color: _darkText,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'La tua dashboard per ricette, dispensa e pasti.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Statistiche',
            color: AppTheme.primaryColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection({
    required BuildContext context,
    required List<Recipe> recipes,
  }) {
    return _DailySuggestionSlider(recipes: recipes);
  }


  Widget _buildStatsGrid({
    required BuildContext context,
    required int recipesCount,
    required int mealPlansCount,
    required int expiringCount,
    required int suggestableCount,
  }) {
    final stats = [
      _DashboardStat(
        title: 'Ricette',
        value: recipesCount.toString(),
        subtitle: 'totali salvate',
        icon: Icons.menu_book_rounded,
        color: AppTheme.primaryColor,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipesScreen())),
      ),
      _DashboardStat(
        title: 'Pasti',
        value: mealPlansCount.toString(),
        subtitle: 'programmati',
        icon: Icons.calendar_month_rounded,
        color: AppTheme.accentColor,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MealPlanScreen())),
      ),
      _DashboardStat(
        title: 'Scadenze',
        value: expiringCount.toString(),
        subtitle: 'da controllare',
        icon: Icons.warning_amber_rounded,
        color: Colors.redAccent,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantryScreen(initialShowOnlyExpiring: true))),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;
        final crossAxisCount = isDesktop ? 3 : 2;

        return GridView.builder(
          itemCount: stats.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 115,
          ),
          itemBuilder: (context, index) {
            final stat = stats[index];

            return GestureDetector(
              onTap: stat.onTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: _softCardDecoration(),
                child: Row(
                  children: [
                  _circleIcon(icon: stat.icon, color: stat.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.value,
                          style: TextStyle(
                            color: stat.color,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          stat.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _darkText,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stat.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _mutedText,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        );
      },
    );
  }


  Widget _buildChartCard(BuildContext context, Map<String, int> categories) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _softCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.donut_large_rounded,
            title: 'Distribuzione ricette',
          ),
          const SizedBox(height: 16),
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'Nessuna ricetta presente.',
                  style: TextStyle(color: _mutedText),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;

                final chart = SizedBox(
                  height: 240,
                  width: isWide ? 290 : double.infinity,
                  child: _buildChart(categories),
                );

                final legend = _buildChartLegend(categories);

                if (isWide) {
                  return Row(
                    children: [
                      chart,
                      const SizedBox(width: 28),
                      Expanded(child: legend),
                    ],
                  );
                }

                return Column(
                  children: [chart, const SizedBox(height: 16), legend],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildChart(Map<String, int> categories) {
    final colors = _chartColors();

    int colorIndex = 0;
    final sections = categories.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: entry.value.toString(),
        radius: 75,
        titleStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 50,
        sectionsSpace: 3,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildChartLegend(Map<String, int> categories) {
    final colors = _chartColors();

    int index = 0;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.entries.map((entry) {
        final color = colors[index % colors.length];
        index++;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withOpacity(0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              Text(
                '${entry.key} (${entry.value})',
                style: const TextStyle(
                  color: _darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _darkText,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _circleIcon({required IconData icon, required Color color}) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(icon, color: color, size: 25),
    );
  }

  Widget _glassIcon(IconData icon) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }

  BoxDecoration _softCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.055),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  List<Color> _chartColors() {
    return [
      AppTheme.primaryColor,
      AppTheme.accentColor,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber.shade700,
    ];
  }
}

class _DashboardStat {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardStat({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}


class _DailySuggestionSlider extends StatefulWidget {
  final List<Recipe> recipes;
  const _DailySuggestionSlider({required this.recipes});

  @override
  State<_DailySuggestionSlider> createState() => _DailySuggestionSliderState();
}

class _DailySuggestionSliderState extends State<_DailySuggestionSlider> {
  final PageController _pageController = PageController();
  final List<String> _categories = ['Colazione', 'Spuntino', 'Primo', 'Secondo', 'Dolce'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dailySuggestions = [];
    for (String cat in _categories) {
      final matches = widget.recipes.where((r) => r.category == cat).toList();
      if (matches.isNotEmpty) {
        dailySuggestions.add({'category': cat, 'recipe': matches.first});
      } else {
        dailySuggestions.add({'category': cat, 'recipe': null});
      }
    }

    return Container(
      width: double.infinity,
      height: 270,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF388E3C), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: dailySuggestions.length,
            itemBuilder: (context, index) {
              final suggestion = dailySuggestions[index];
              final String catName = suggestion['category'];
              final recipe = suggestion['recipe'];

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cosa cucino oggi? ($catName)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (recipe != null) ...[
                      Text(
                        'Una fantastica idea per te:',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.90),
                          fontSize: 15.5,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        recipe.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF388E3C),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Vedi ricetta', style: TextStyle(fontWeight: FontWeight.w800)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeId: recipe.id)));
                        },
                      ),
                    ] else ...[
                      Text(
                        'Nessuna ricetta suggeribile.\nAggiungi ingredienti freschi in dispensa per ricevere consigli!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.90),
                          fontSize: 15.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                  onPressed: _prevPage,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
                  onPressed: _nextPage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
