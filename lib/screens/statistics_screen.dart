import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final expenses = provider.expenses;
        final categoryData = _getCategoryData(expenses);

        return Scaffold(
          appBar: AppBar(title: const Text('Statistics')),
          body: expenses.isEmpty
              ? const Center(child: Text('No data for statistics'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category Breakdown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 300,
                        child:
                            PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 60,
                                sections: categoryData.entries.map((entry) {
                                  return PieChartSectionData(
                                    color: _getCategoryColor(entry.key),
                                    value: entry.value,
                                    title:
                                        '${((entry.value / provider.totalForSelectedPerson) * 100).toStringAsFixed(0)}%',
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ).animate().scale(
                              duration: 600.ms,
                              curve: Curves.easeOutBack,
                            ),
                      ),
                      const SizedBox(height: 40),
                      ...categoryData.entries
                          .map(
                            (entry) =>
                                _buildCategoryRow(entry.key, entry.value),
                          )
                          .toList(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Map<String, double> _getCategoryData(List<dynamic> expenses) {
    Map<String, double> data = {};
    for (var expense in expenses) {
      data[expense.category] = (data[expense.category] ?? 0) + expense.amount;
    }
    return data;
  }

  Widget _buildCategoryRow(String category, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(category, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.pink;
      case 'bills':
        return Colors.purple;
      case 'health':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
