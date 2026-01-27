import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_provider.dart';
import '../widgets/glass_container.dart';
import 'main_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/app_theme.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController(
    text: '10000',
  );
  final List<String> _avatars = [
    '👤',
    '👨‍💻',
    '👩‍🎨',
    '🙋‍♂️',
    '🙋‍♀️',
    '🕶️',
    '🚀',
    '🐱',
  ];
  String _selectedAvatar = '👤';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ExpenseProvider>().fetchPersons());
  }

  void _showAddPersonDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            title: const Text(
              'Create Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Profile Name',
                        hintText: 'e.g. Personal, Business',
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Monthly Budget',
                        prefixText: '₹ ',
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Choose Avatar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _avatars.length,
                        itemBuilder: (context, index) {
                          final avatar = _avatars[index];
                          final isSelected = _selectedAvatar == avatar;
                          return GestureDetector(
                            onTap: () =>
                                setDialogState(() => _selectedAvatar = avatar),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white30
                                      : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                avatar,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
                  if (_nameController.text.isNotEmpty) {
                    final budget =
                        double.tryParse(_budgetController.text) ?? 10000.0;
                    context.read<ExpenseProvider>().addPerson(
                      _nameController.text,
                      _selectedAvatar,
                      budget,
                    );
                    _nameController.clear();
                    _budgetController.text = '10000';
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text(
          'Delete Profile?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete ${person.name}? All associated expenses will be permanently removed.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
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
              backgroundColor: AppTheme.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.read<ExpenseProvider>().deletePerson(person.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
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
    return Scaffold(
      body: Stack(
        children: [
          // Premium Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E1B4B),
                  Color(0xFF0F172A),
                ],
              ),
            ),
          ),

          // Animated Decorative Orbs
          Positioned(
            top: -100,
            left: -100,
            child:
                Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: 3.seconds,
                      curve: Curves.easeInOut,
                    ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Text(
                        'Expence\nTracker Pro',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                              letterSpacing: -1,
                            ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .slideX(begin: -0.2, end: 0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 16),

                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ).animate().fadeIn(delay: 400.ms).scaleX(begin: 0, end: 1),

                  const SizedBox(height: 24),

                  Text(
                    'Manage expenses efficiently with personal profiles and smart tracking.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 48),

                  Expanded(
                    child: Consumer<ExpenseProvider>(
                      builder: (context, provider, child) {
                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                childAspectRatio: 0.9,
                              ),
                          itemCount: provider.persons.length + 1,
                          itemBuilder: (context, index) {
                            if (index == provider.persons.length) {
                              return GestureDetector(
                                onTap: _showAddPersonDialog,
                                child: GlassContainer(
                                  opacity: 0.05,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.05,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add_rounded,
                                          size: 32,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'New Profile',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(delay: 800.ms).scale();
                            }

                            final person = provider.persons[index];
                            return GestureDetector(
                                  onTap: () {
                                    provider.selectPerson(person);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const MainScreen(),
                                      ),
                                    );
                                  },
                                  onLongPress: () =>
                                      _showDeleteConfirmation(context, person),
                                  child: GlassContainer(
                                    opacity: 0.1,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.primaryColor
                                                    .withValues(alpha: 0.2),
                                                blurRadius: 20,
                                                spreadRadius: -5,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            person.avatar,
                                            style: const TextStyle(
                                              fontSize: 40,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          person.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Hold to delete',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: (800 + (index * 100)).ms)
                                .slideY(begin: 0.1, end: 0);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
