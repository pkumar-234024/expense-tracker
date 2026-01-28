import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_provider.dart';
import '../core/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'debt_detail_screen.dart';
import 'package:intl/intl.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final debts = provider.debts;
        final totalLent = debts.fold(0.0, (sum, d) => sum + d.amount);
        final totalPending = debts.fold(
          0.0,
          (sum, d) => sum + provider.getDebtRemainingAmount(d),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Lending & Debts'),
            backgroundColor: AppTheme.backgroundColor,
          ),
          body: Column(
            children: [
              if (debts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.8),
                        AppTheme.primaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        'Total Lent',
                        '₹${totalLent.toStringAsFixed(0)}',
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildSummaryItem(
                        'Pending',
                        '₹${totalPending.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(),
              Expanded(
                child: debts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.handshake_outlined,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No active lendings',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: debts.length,
                        itemBuilder: (context, index) {
                          final debt = debts[index];
                          final remaining = provider.getDebtRemainingAmount(
                            debt,
                          );

                          return Card(
                            color: AppTheme.surfaceColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DebtDetailScreen(debt: debt),
                                ),
                              ),
                              title: Text(
                                debt.borrowerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                'Given on ${DateFormat('dd MMM yyyy').format(debt.date)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${remaining.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: remaining > 0
                                          ? Colors.orangeAccent
                                          : Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Total: ₹${debt.amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn().slideX();
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddDebtDialog(context),
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.person_add_rounded, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text('New Lending'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Borrower Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Total Amount',
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.calendar_month_rounded, size: 20),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0;
                if (name.isNotEmpty && amount > 0) {
                  context.read<ExpenseProvider>().addDebt(
                    name,
                    amount,
                    selectedDate,
                    notesController.text.trim(),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
