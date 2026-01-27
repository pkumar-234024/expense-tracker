import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/expense.dart';
import '../core/app_theme.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const ExpenseCard({super.key, required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getCategoryEmoji(expense.category),
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(expense.date),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppTheme.errorColor,
                ),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return '🍔';
      case 'transport':
        return '🚗';
      case 'shopping':
        return '🛍️';
      case 'bills':
        return '🧾';
      case 'health':
        return '🏥';
      default:
        return '💰';
    }
  }
}
