import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;

  List<Task> _allTasks = [];
  bool _isLoading = true;
  bool _isSaving = false;

  String _searchQuery = '';
  TaskStatus? _filterStatus;

  // Debounce for search
  Timer? _debounceTimer;

  // Exposed list of tasks after applying search and filtering
  List<Task> _filteredTasks = [];

  TaskProvider(this._repository) {
    _loadTasks();
  }

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get searchQuery => _searchQuery;
  TaskStatus? get filterStatus => _filterStatus;
  List<Task> get tasks => _filteredTasks;
  List<Task> get allTasks => _allTasks;

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();
    
    _allTasks = await _repository.getTasks();
    _applyFiltersAndSearch();
    
    _isLoading = false;
    notifyListeners();
  }

  void _applyFiltersAndSearch() {
    _filteredTasks = _allTasks.where((task) {
      final matchesStatus = _filterStatus == null || task.status == _filterStatus;
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    // Sort by due date natively
    _filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  void setSearchQuery(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query;
      _applyFiltersAndSearch();
      notifyListeners();
    });
  }

  void setFilterStatus(TaskStatus? status) {
    _filterStatus = status;
    _applyFiltersAndSearch();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _isSaving = true;
    notifyListeners();

    // Simulate 2-second delay
    await Future.delayed(const Duration(seconds: 2));

    _allTasks.add(task);
    await _repository.saveTasks(_allTasks);
    
    _applyFiltersAndSearch();
    _isSaving = false;
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    _isSaving = true;
    notifyListeners();

    // Simulate 2-second delay
    await Future.delayed(const Duration(seconds: 2));

    final index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _allTasks[index] = task;
      
      // Update any tasks that are blocked by this task if needed 
      // (not strictly necessary to actively update unless UI needs immediate reactivity of blocked state, which simple redraw handles as it depends on task.status)
      await _repository.saveTasks(_allTasks);
      _applyFiltersAndSearch();
    }
    
    _isSaving = false;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _allTasks.removeWhere((t) => t.id == id);
    
    // Clear blockedById for any tasks blocked by the deleted task
    for (int i = 0; i < _allTasks.length; i++) {
        if (_allTasks[i].blockedById == id) {
             _allTasks[i] = _allTasks[i].copyWith(blockedById: '');
        }
    }
    
    await _repository.saveTasks(_allTasks);
    _applyFiltersAndSearch();
    notifyListeners();
  }
}
