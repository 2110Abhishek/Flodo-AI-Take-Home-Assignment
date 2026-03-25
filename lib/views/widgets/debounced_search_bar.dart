import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/task_provider.dart';

class DebouncedSearchBar extends StatefulWidget {
  const DebouncedSearchBar({super.key});

  @override
  State<DebouncedSearchBar> createState() => _DebouncedSearchBarState();
}

class _DebouncedSearchBarState extends State<DebouncedSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<TaskProvider>().searchQuery,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1), size: 28),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    _controller.clear();
                    context.read<TaskProvider>().setSearchQuery('');
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (value) {
          context.read<TaskProvider>().setSearchQuery(value);
          setState(() {});
        },
      ),
    );
  }
}
