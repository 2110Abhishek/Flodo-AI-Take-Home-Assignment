import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../viewmodels/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? existingTask;

  const TaskFormScreen({super.key, this.existingTask});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _dueDate;
  late TaskStatus _status;
  String? _blockedById;

  bool _isSaving = false;
  bool _isLoadingDraft = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    
    if (widget.existingTask != null) {
      final t = widget.existingTask!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _dueDate = t.dueDate;
      _status = t.status;
      _blockedById = t.blockedById;
    } else {
      _dueDate = DateTime.now();
      _status = TaskStatus.todo;
      _loadDraft();
    }

    _titleController.addListener(_saveDraft);
    _descController.addListener(_saveDraft);
  }

  @override
  void dispose() {
    _titleController.removeListener(_saveDraft);
    _descController.removeListener(_saveDraft);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    setState(() => _isLoadingDraft = true);
    final prefs = await SharedPreferences.getInstance();
    _titleController.text = prefs.getString('draft_title') ?? '';
    _descController.text = prefs.getString('draft_desc') ?? '';
    setState(() => _isLoadingDraft = false);
  }

  void _saveDraft() {
    if (widget.existingTask != null) return;
    
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('draft_title', _titleController.text);
      prefs.setString('draft_desc', _descController.text);
    });
  }
  
  Future<void> _clearDraft() async {
    if (widget.existingTask != null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_title');
    await prefs.remove('draft_desc');
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final provider = context.read<TaskProvider>();
    
    final task = Task(
      id: widget.existingTask?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descController.text,
      dueDate: _dueDate,
      status: _status,
      blockedById: _blockedById,
    );

    if (widget.existingTask != null) {
      await provider.updateTask(task);
    } else {
      await provider.addTask(task);
      await _clearDraft();
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDraft) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final provider = context.watch<TaskProvider>();
    final availableTasks = provider.allTasks.where((t) => t.id != widget.existingTask?.id).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE2E8F0), Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.existingTask == null ? 'New Task' : 'Edit Task'),
          actions: [
            if (widget.existingTask != null && !_isSaving)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                  style: IconButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1)),
                  onPressed: () async {
                    setState(() => _isSaving = true);
                    await context.read<TaskProvider>().deleteTask(widget.existingTask!.id);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCardWrapper(
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title', hintText: 'What needs to be done?'),
                    enabled: !_isSaving,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildCardWrapper(
                  child: TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description', hintText: 'Add some details...'),
                    maxLines: 4,
                    enabled: !_isSaving,
                    validator: (val) => val == null || val.isEmpty ? 'Please enter a description' : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildCardWrapper(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Due Date', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(DateFormat.yMMMd().format(_dueDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF6366F1))
                    ),
                    onTap: _isSaving ? null : _pickDate,
                  ),
                ),
                const SizedBox(height: 20),
                _buildCardWrapper(
                  child: DropdownButtonFormField<TaskStatus>(
                    decoration: const InputDecoration(labelText: 'Status'),
                    value: _status,
                    icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF6366F1)),
                    items: TaskStatus.values.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    )).toList(),
                    onChanged: _isSaving ? null : (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildCardWrapper(
                  child: DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(labelText: 'Blocked By (Optional)'),
                    value: _blockedById,
                    icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF6366F1)),
                    hint: const Text('Select a task'),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('None', style: TextStyle(fontWeight: FontWeight.w600))),
                      ...availableTasks.map((t) => DropdownMenuItem<String?>(
                        value: t.id,
                        child: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      )),
                    ],
                    onChanged: _isSaving ? null : (val) {
                      setState(() => _blockedById = val);
                    },
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isSaving ? [] : [
                      const BoxShadow(
                        color: Color(0x666366F1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      )
                    ]
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : const Text('Save Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
