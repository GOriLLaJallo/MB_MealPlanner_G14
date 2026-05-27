import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/app_provider.dart';
import '../utils/theme.dart';
import 'recipe_detail_screen.dart';
import 'statistics_screen.dart';

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
                            suggestable: suggestable,
                            recipesCount: recipesCount,
                            mealPlansCount: mealPlansCount,
                            expiringCount: expiringItems.length,
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
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _buildAttentionSection(
                                    context,
                                    expiringItems.length,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  flex: 4,
                                  child: _buildSmartTipsCard(context),
                                ),
                              ],
                            )
                          else ...[
                            _buildAttentionSection(
                              context,
                              expiringItems.length,
                            ),
                            const SizedBox(height: 18),
                            _buildSmartTipsCard(context),
                          ],
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
    required List<dynamic> suggestable,
    required int recipesCount,
    required int mealPlansCount,
    required int expiringCount,
  }) {
    final hasSuggestion = suggestable.isNotEmpty;
    final suggestion = hasSuggestion ? suggestable.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E7D32), // Forest Green
            Color(0xFF388E3C), // Green
            Color(0xFF4CAF50), // Light Green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;

          final leftContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _glassIcon(Icons.restaurant_menu_rounded),
                  const SizedBox(width: 12),
                  const Text(
                    'Cosa cucino oggi?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                hasSuggestion
                    ? 'In base alla tua dispensa puoi preparare:'
                    : 'Aggiungi prodotti in dispensa per ricevere suggerimenti automatici.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.90),
                  fontSize: 15.5,
                  height: 1.3,
                ),
              ),
              if (hasSuggestion) ...[
                const SizedBox(height: 7),
                Text(
                  suggestion.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                    'Vedi ricetta',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RecipeDetailScreen(recipeId: suggestion.id),
                      ),
                    );
                  },
                ),
              ],
            ],
          );

          final rightContent = _buildHeroMiniStats(
            recipesCount: recipesCount,
            mealPlansCount: mealPlansCount,
            expiringCount: expiringCount,
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 6, child: leftContent),
                const SizedBox(width: 24),
                Expanded(flex: 4, child: rightContent),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [leftContent, const SizedBox(height: 22), rightContent],
          );
        },
      ),
    );
  }

  Widget _buildHeroMiniStats({
    required int recipesCount,
    required int mealPlansCount,
    required int expiringCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.17),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Column(
        children: [
          _heroStatLine(
            icon: Icons.menu_book_rounded,
            label: 'Ricette salvate',
            value: recipesCount.toString(),
          ),
          const SizedBox(height: 13),
          _heroStatLine(
            icon: Icons.calendar_month_rounded,
            label: 'Pasti nei prossimi 7 giorni',
            value: mealPlansCount.toString(),
          ),
          const SizedBox(height: 13),
          _heroStatLine(
            icon: Icons.warning_amber_rounded,
            label: 'Prodotti da controllare',
            value: expiringCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _heroStatLine({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
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
      ),
      _DashboardStat(
        title: 'Pasti',
        value: mealPlansCount.toString(),
        subtitle: 'programmati',
        icon: Icons.calendar_month_rounded,
        color: AppTheme.accentColor,
      ),
      _DashboardStat(
        title: 'Scadenze',
        value: expiringCount.toString(),
        subtitle: 'da controllare',
        icon: Icons.warning_amber_rounded,
        color: Colors.redAccent,
      ),
      _DashboardStat(
        title: 'Consigli',
        value: suggestableCount.toString(),
        subtitle: 'ricette possibili',
        icon: Icons.tips_and_updates_rounded,
        color: Colors.purple,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;
        final crossAxisCount = isDesktop ? 4 : 2;

        return GridView.builder(
          itemCount: stats.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isDesktop ? 2.35 : 1.45,
          ),
          itemBuilder: (context, index) {
            final stat = stats[index];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: _softCardDecoration(),
              child: Row(
                children: [
                  _circleIcon(icon: stat.icon, color: stat.color),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat.value,
                          style: TextStyle(
                            color: stat.color,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          stat.title,
                          style: const TextStyle(
                            color: _darkText,
                            fontSize: 15,
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
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAttentionSection(BuildContext context, int expiringCount) {
    final hasAlert = expiringCount > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasAlert ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: hasAlert ? Colors.red.shade100 : Colors.green.shade100,
        ),
      ),
      child: Row(
        children: [
          _circleIcon(
            icon: hasAlert
                ? Icons.warning_amber_rounded
                : Icons.check_circle_rounded,
            color: hasAlert ? Colors.redAccent : Colors.green,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAlert
                      ? 'Attenzione alle scadenze'
                      : 'Dispensa sotto controllo',
                  style: TextStyle(
                    color: hasAlert
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  hasAlert
                      ? 'Hai $expiringCount prodotti in scadenza o già scaduti. Controllali nella sezione Dispensa.'
                      : 'Non risultano prodotti in scadenza nei prossimi giorni.',
                  style: const TextStyle(
                    color: _mutedText,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartTipsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _softCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            icon: Icons.auto_awesome_rounded,
            title: 'Funzioni smart',
          ),
          const SizedBox(height: 15),
          _smartTipRow(
            icon: Icons.shopping_cart_checkout_rounded,
            title: 'Lista spesa automatica',
            subtitle: 'Generata confrontando piano pasti e dispensa.',
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _smartTipRow(
            icon: Icons.restaurant_rounded,
            title: 'Ricette consigliate',
            subtitle: 'Suggerite in base agli ingredienti disponibili.',
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          _smartTipRow(
            icon: Icons.event_busy_rounded,
            title: 'Controllo scadenze',
            subtitle: 'Evidenzia prodotti vicini alla scadenza.',
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _smartTipRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.11),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _darkText,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _mutedText,
                  fontSize: 12.8,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
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

  const _DashboardStat({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
