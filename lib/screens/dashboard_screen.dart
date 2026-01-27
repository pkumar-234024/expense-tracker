import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/add_expense_form.dart';
import '../core/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseForm(
        onSave: (title, amount, category) {
          context.read<ExpenseProvider>().addExpense(title, amount, category);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final person = provider.selectedPerson;
        if (person == null) return const Scaffold();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryColor, Color(0xFF4F46E5)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Balance',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${provider.totalForSelectedPerson.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn().scale(),
                        ],
                      ),
                    ),
                  ),
                  title: Text('${person.name}\'s Expenses'),
                  centerTitle: true,
                ),
                actions: [
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
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
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
                          color: Colors.white.withOpacity(0.1),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses yet',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
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
                      );
                    }, childCount: provider.expenses.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddExpenseModal(context),
            backgroundColor: AppTheme.accentColor,
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
