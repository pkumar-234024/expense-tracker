import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/add_expense_form.dart';
import '../core/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/expense.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showAddExpenseModal(BuildContext context, {Expense? existingExpense}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseForm(
        existingExpense: existingExpense,
        onSave: (title, amount, category, date) {
          final provider = context.read<ExpenseProvider>();
          if (existingExpense != null) {
            final updatedExpense = Expense(
              id: existingExpense.id,
              personId: existingExpense.personId,
              title: title,
              amount: amount,
              category: category,
              date: date,
            );
            provider.updateExpense(updatedExpense);
          } else {
            provider.addExpense(title, amount, category, date);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    final controller = TextEditingController(
      text: provider.monthlyBudget.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Edit Monthly Budget',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'New Budget',
            prefixText: '₹ ',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final budget = double.tryParse(controller.text);
              if (budget != null && provider.selectedPerson != null) {
                provider.updatePersonBudget(
                  provider.selectedPerson!.id,
                  budget,
                );
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Update',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final person = provider.selectedPerson;
        if (person == null) return const Scaffold();

        final isOverBudget = provider.remainingBudget < 0;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isOverBudget
                            ? [const Color(0xFFEF4444), const Color(0xFF991B1B)]
                            : [AppTheme.primaryColor, const Color(0xFF4F46E5)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isOverBudget
                                ? 'Budget Exceeded'
                                : 'Remaining Budget',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${provider.remainingBudget.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn().scale(),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Spent: ₹${provider.totalForSelectedPerson.toStringAsFixed(0)} / ₹${provider.monthlyBudget.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  title: Text('${person.name}\'s Expenses'),
                  centerTitle: true,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded),
                    onPressed: () => _showEditBudgetDialog(context),
                    tooltip: 'Edit Budget',
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      provider.logout();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${provider.expenses.length} items',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.expenses.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses yet',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final expense = provider.expenses[index];
                      return ExpenseCard(
                        expense: expense,
                        onDelete: () => provider.removeExpense(expense.id),
                        onEdit: () => _showAddExpenseModal(
                          context,
                          existingExpense: expense,
                        ),
                      );
                    }, childCount: provider.expenses.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddExpenseModal(context),
            backgroundColor: isOverBudget
                ? const Color(0xFFEF4444)
                : AppTheme.accentColor,
            elevation: 8,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add Expense',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).animate().slideY(begin: 1.0, end: 0, delay: 400.ms),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
