import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class AddExpenseForm extends StatefulWidget {
  final Function(String title, double amount, String category) onSave;

  const AddExpenseForm({super.key, required this.onSave});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  final _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Expense',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Expense Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '₹ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(cat),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                final title = _titleController.text;
                final amount = double.tryParse(_amountController.text);
                if (title.isNotEmpty && amount != null) {
                  widget.onSave(title, amount, _selectedCategory);
                }
              },
              child: const Text(
                'Save Expense',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
