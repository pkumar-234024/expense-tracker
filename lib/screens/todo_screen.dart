import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_provider.dart';
import '../core/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final todos = provider.todos;
        final completedCount = todos.where((t) => t.isCompleted).length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('To-Do List'),
            backgroundColor: AppTheme.backgroundColor,
          ),
          body: Column(
            children: [
              if (todos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Progress',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$completedCount of ${todos.length} tasks completed',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      CircularProgressIndicator(
                        value: todos.isEmpty
                            ? 0
                            : completedCount / todos.length,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),
              Expanded(
                child: todos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.checklist_rounded,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks yet',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return Dismissible(
                            key: Key(todo.id),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.redAccent,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              provider.removeTodo(todo.id);
                            },
                            child: Card(
                              color: AppTheme.surfaceColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: CheckboxListTile(
                                value: todo.isCompleted,
                                onChanged: (val) {
                                  provider.toggleTodo(todo.id, val ?? false);
                                },
                                title: Text(
                                  todo.task,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: todo.isCompleted
                                        ? Colors.white.withValues(alpha: 0.3)
                                        : Colors.white,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (todo.description != null &&
                                        todo.description!.isNotEmpty)
                                      Text(
                                        todo.description!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: todo.isCompleted
                                              ? Colors.white.withValues(
                                                  alpha: 0.2,
                                                )
                                              : Colors.white.withValues(
                                                  alpha: 0.6,
                                                ),
                                        ),
                                      ),
                                    if (todo.dueDate != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          'Due: ${DateFormat('dd MMM yyyy').format(todo.dueDate!)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: todo.isCompleted
                                                ? Colors.white.withValues(
                                                    alpha: 0.1,
                                                  )
                                                : AppTheme.accentColor
                                                      .withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                activeColor: AppTheme.accentColor,
                                checkColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ).animate().fadeIn().slideX();
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'todo_fab',
            onPressed: () => _showAddTodoDialog(context, provider),
            backgroundColor: AppTheme.accentColor,
            child: const Icon(Icons.add_task_rounded, color: Colors.black),
          ),
        );
      },
    );
  }

  void _showAddTodoDialog(BuildContext context, ExpenseProvider provider) {
    final taskController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: taskController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'e.g., Pay electricity bill',
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Short Description',
                    hintText: 'Add some details...',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    selectedDate == null
                        ? 'No due date set'
                        : 'Due: ${DateFormat('dd MMM yyyy').format(selectedDate!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.calendar_today_rounded, size: 20),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
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
                final task = taskController.text.trim();
                final description = descriptionController.text.trim();
                if (task.isNotEmpty) {
                  provider.addTodo(
                    task,
                    description.isEmpty ? null : description,
                    selectedDate,
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
