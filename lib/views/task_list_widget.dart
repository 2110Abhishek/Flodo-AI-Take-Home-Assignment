import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../viewmodels/task_provider.dart';
import 'task_form_screen.dart';

class TaskListWidget extends StatelessWidget {
  const TaskListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 80, color: Color(0xFFCBD5E1)),
                SizedBox(height: 16),
                Text(
                  'No tasks available',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120, top: 8),
          itemCount: provider.tasks.length,
          itemBuilder: (context, index) {
            final task = provider.tasks[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: _TaskCard(task: task),
            );
          },
        );
      },
    );
  }
}

class _TaskCard extends StatefulWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
        lowerBound: 0.0,
        upperBound: 0.03,
    )..addListener(() {
        setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isTaskBlocked(BuildContext context) {
    if (widget.task.blockedById == null || widget.task.blockedById!.isEmpty) return false;
    final provider = context.read<TaskProvider>();
    try {
      final blockingTask = provider.allTasks.firstWhere((t) => t.id == widget.task.blockedById);
      return blockingTask.status != TaskStatus.done;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = _isTaskBlocked(context);
    final searchQuery = context.select<TaskProvider, String>((p) => p.searchQuery);
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
         _controller.reverse();
         Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => TaskFormScreen(existingTask: widget.task),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                return SlideTransition(
                  position: animation.drive(Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic))), 
                  child: child
                );
              },
            ),
          );
      },
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(
        scale: _scale,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isBlocked ? 0.6 : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF94A3B8).withOpacity(0.3),
                  offset: const Offset(4, 12),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-8, -8),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _HighlightedText(
                          text: widget.task.title,
                          query: searchQuery,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StatusBadge(status: widget.task.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.task.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                           color: Colors.black.withOpacity(0.02),
                           offset: const Offset(0, 2),
                           blurRadius: 4,
                        )
                      ]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat.yMMMd().format(widget.task.dueDate),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (isBlocked)
                          const Row(
                            children: [
                              Icon(Icons.lock_rounded, size: 18, color: Color(0xFFEF4444)),
                              SizedBox(width: 4),
                              Text(
                                'Blocked',
                                style: TextStyle(fontSize: 13, color: Color(0xFFEF4444), fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case TaskStatus.todo:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        icon = Icons.radio_button_unchecked_rounded;
        break;
      case TaskStatus.inProgress:
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        icon = Icons.hourglass_top_rounded;
        break;
      case TaskStatus.done:
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF059669);
        icon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 2,
            offset: Offset(-1, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      return Text(text, style: style);
    }

    final int startIndex = lowerText.indexOf(lowerQuery);
    final int endIndex = startIndex + query.length;

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: style.copyWith(
              backgroundColor: const Color(0xFFFDE047),
              color: const Color(0xFF854D0E),
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }
}
