import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class AddExpenseForm extends StatefulWidget {
  final Expense? existingExpense;
  final Function(String title, double amount, String category, DateTime date)
  onSave;

  const AddExpenseForm({super.key, required this.onSave, this.existingExpense});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late String _selectedCategory;
  late DateTime _selectedDate;

  final _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingExpense?.title ?? '',
    );
    _amountController = TextEditingController(
      text: widget.existingExpense != null
          ? widget.existingExpense!.amount.toString()
          : '',
    );
    _selectedCategory = widget.existingExpense?.category ?? 'Food';
    _selectedDate = widget.existingExpense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingExpense != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Expense' : 'Add New Expense',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Date Picker Item
              InkWell(
                onTap: _presentDatePicker,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM, yyyy').format(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
                      widget.onSave(
                        title,
                        amount,
                        _selectedCategory,
                        _selectedDate,
                      );
                    }
                  },
                  child: Text(
                    isEditing ? 'Update Expense' : 'Save Expense',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
