import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_provider.dart';
import '../widgets/glass_container.dart';
import 'main_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  final TextEditingController _nameController = TextEditingController();
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
      builder: (context) => AlertDialog(
        title: const Text('New Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _avatars
                    .map(
                      (avatar) => GestureDetector(
                        onTap: () => setState(() => _selectedAvatar = avatar),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: _selectedAvatar == avatar
                                ? Border.all(color: Colors.blue)
                                : null,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            avatar,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                context.read<ExpenseProvider>().addPerson(
                  _nameController.text,
                  _selectedAvatar,
                );
                _nameController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
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
          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ).animate().scale(delay: 500.ms, duration: 2.seconds),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Choose\nYour Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 40,
                      height: 1.1,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 10),
                  Text(
                    'Select a profile to manage expenses',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: Consumer<ExpenseProvider>(
                      builder: (context, provider, child) {
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                          itemCount: provider.persons.length + 1,
                          itemBuilder: (context, index) {
                            if (index == provider.persons.length) {
                              return GestureDetector(
                                onTap: _showAddPersonDialog,
                                child: const GlassContainer(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_rounded,
                                        size: 40,
                                        color: Colors.white54,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Add Profile',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                ),
                              );
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
                              child: GlassContainer(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      person.avatar,
                                      style: const TextStyle(fontSize: 50),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      person.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: (index * 100).ms).scale();
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
