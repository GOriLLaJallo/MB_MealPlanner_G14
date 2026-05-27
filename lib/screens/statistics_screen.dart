import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche & Abitudini'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final mealPlans = provider.mealPlans;

          if (mealPlans.isEmpty) {
            return const Center(child: Text('Nessun pasto pianificato. Aggiungi pasti per vedere le tue abitudini.'));
          }

          // 1. Frequenza Pasti per Giorno
          Map<int, int> mealsPerDay = {};
          for (var plan in mealPlans) {
            final weekday = plan.date.weekday; // 1 = Monday, 7 = Sunday
            mealsPerDay[weekday] = (mealsPerDay[weekday] ?? 0) + 1;
          }

          // 2. Tipi di Pasto più frequenti
          Map<String, int> mealTypes = {};
          for (var plan in mealPlans) {
            mealTypes[plan.mealType] = (mealTypes[plan.mealType] ?? 0) + 1;
          }

          // 3. Ingredienti più usati
          Map<String, int> ingredientCounts = {};
          for (var recipe in provider.recipes) {
            for (var ing in recipe.ingredients) {
              final name = ing.name.toLowerCase();
              ingredientCounts[name] = (ingredientCounts[name] ?? 0) + 1;
            }
          }
          final sortedIngredients = ingredientCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final topIngredients = sortedIngredients.take(5).toList();

          // 4. Tempo medio di preparazione
          double avgPrepTime = 0;
          if (provider.recipes.isNotEmpty) {
            avgPrepTime = provider.recipes.map((r) => r.prepTimeMinutes).reduce((a, b) => a + b) / provider.recipes.length;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pasti per Giorno (Settimana)', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildBarChart(mealsPerDay),
                const SizedBox(height: 32),
                Text('Tipi di Pasto (Abitudini)', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildPieChart(mealTypes),
                const SizedBox(height: 32),
                Text('Ingredienti Più Usati (Top 5)', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                if (topIngredients.isEmpty)
                  const Text('Nessun ingrediente trovato.')
                else
                  ...topIngredients.map((e) => ListTile(
                        leading: const Icon(Icons.star, color: Colors.amber),
                        title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        trailing: Text('${e.value} ricette', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        contentPadding: EdgeInsets.zero,
                      )),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer, size: 40, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tempo Medio Preparazione', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${avgPrepTime.toStringAsFixed(0)} minuti', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarChart(Map<int, int> data) {
    // Weekdays from 1 to 7
    List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= 7; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (data[i] ?? 0).toDouble(),
              color: AppTheme.primaryColor,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (data.values.isEmpty ? 5 : data.values.reduce((a, b) => a > b ? a : b).toDouble()) + 2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
                  if (value.toInt() >= 1 && value.toInt() <= 7) {
                    return Text(days[value.toInt() - 1]);
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value % 1 == 0) {
                    return Text(value.toInt().toString());
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> types) {
    final List<Color> colors = [Colors.blue, Colors.orange, Colors.purple, Colors.green, Colors.red];
    int colorIndex = 0;

    List<PieChartSectionData> sections = types.entries.map((e) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '${e.key}\n(${e.value})',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 30,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}
