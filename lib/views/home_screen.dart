import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../viewmodels/task_provider.dart';
import 'task_list_widget.dart';
import 'widgets/debounced_search_bar.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE2E8F0), 
            Color(0xFFF8FAFC),
            Color(0xFFE2E8F0),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text('Tasks', style: TextStyle(shadows: [Shadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 10)])),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Consumer<TaskProvider>(
                builder: (context, provider, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ]
                    ),
                    child: DropdownButton<TaskStatus?>(
                      value: provider.filterStatus,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1E293B)),
                      underline: const SizedBox(),
                      hint: const Text('Filter', style: TextStyle(fontWeight: FontWeight.w700)),
                      onChanged: (TaskStatus? newValue) {
                        provider.setFilterStatus(newValue);
                      },
                      items: [
                        const DropdownMenuItem<TaskStatus?>(
                          value: null,
                          child: Text('All', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        ...TaskStatus.values.map((status) {
                          return DropdownMenuItem<TaskStatus?>(
                            value: status,
                            child: Text(status.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: const Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Hero(
                tag: 'search_bar',
                child: Material(
                  color: Colors.transparent,
                  child: DebouncedSearchBar()
                )
              ),
            ),
            Expanded(
              child: TaskListWidget(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const TaskFormScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeOutCubic;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(position: animation.drive(tween), child: child);
                },
              ),
            );
          },
          child: const Icon(Icons.add_rounded, size: 36),
        ),
      ),
    );
  }
}
