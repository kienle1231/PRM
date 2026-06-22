import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/user_admin_repository.dart';

/// Manages the admin user management list state.
class UserAdminViewModel extends ChangeNotifier {
  final UserAdminRepository _repo;

  UserAdminViewModel(this._repo);

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _roleFilter = 'all'; // 'all', 'admin', 'user'
  String _statusFilter = 'all'; // 'all', 'active', 'disabled'

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get roleFilter => _roleFilter;
  String get statusFilter => _statusFilter;

  List<UserModel> get allUsers => _users;

  List<UserModel> get filteredUsers {
    var list = _users;

    // Role filter
    if (_roleFilter == 'admin') {
      list = list.where((u) => u.role == 'admin').toList();
    } else if (_roleFilter == 'user') {
      list = list.where((u) => u.role == 'user').toList();
    }

    // Status filter
    if (_statusFilter == 'active') {
      list = list.where((u) => !u.isDisabled).toList();
    } else if (_statusFilter == 'disabled') {
      list = list.where((u) => u.isDisabled).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((u) {
        return u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.phone.contains(q);
      }).toList();
    }

    return list;
  }

  int get totalUsers => _users.length;
  int get activeUsers => _users.where((u) => !u.isDisabled).length;
  int get disabledUsers => _users.where((u) => u.isDisabled).length;
  int get adminCount => _users.where((u) => u.role == 'admin').length;

  // ── Load Users ────────────────────────────────────────────────────────────
  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _repo.getUsers();
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách người dùng';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Toggle Disable ────────────────────────────────────────────────────────
  Future<bool> toggleDisabled(UserModel user) async {
    final newStatus = !user.isDisabled;
    final ok = await _repo.setUserDisabled(user.id, newStatus);
    if (ok) {
      final idx = _users.indexWhere((u) => u.id == user.id);
      if (idx >= 0) {
        _users[idx] = _users[idx].copyWith(isDisabled: newStatus);
        notifyListeners();
      }
    }
    return ok;
  }

  // ── Filters ───────────────────────────────────────────────────────────────
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setRoleFilter(String role) {
    _roleFilter = role;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _roleFilter = 'all';
    _statusFilter = 'all';
    notifyListeners();
  }
}
