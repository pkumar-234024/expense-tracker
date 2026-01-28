import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/expense_provider.dart';
import 'screens/profile_selection_screen.dart';
import 'core/app_theme.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ExpenseProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ProfileSelectionScreen(),
    );
  }
}
