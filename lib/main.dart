import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repositories/task_repository.dart';
import 'viewmodels/task_provider.dart';
import 'utils/app_theme.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(LocalTaskRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Flodo Task Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
