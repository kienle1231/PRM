import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';
import '../repositories/auth_repository.dart';

/// Auth state enumeration.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Manages authentication state across the app.
/// Handles login, register, logout, remember-me, and password reset.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _rememberMe = false;

  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';

  AuthViewModel(this._repo);

  // ── Getters ───────────────────────────────────────────────────────────────
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _status == AuthStatus.loading;

  // ── Initialize ────────────────────────────────────────────────────────────
  /// Called at app launch. Checks remember-me and restores session.
  Future<void> initialize() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _rememberMe = prefs.getBool(_rememberMeKey) ?? false;

      if (_rememberMe) {
        final user = await _repo.getCurrentUser();
        if (user != null) {
          _currentUser = user;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        await _repo.signOut();
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setLoading();
    try {
      final user = await _repo.signIn(email.trim(), password);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;

      // Persist remember-me
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_rememberMeKey, true);
        await prefs.setString(_savedEmailKey, email.trim());
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_rememberMeKey);
        await prefs.remove(_savedEmailKey);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<bool> register(
      String name, String email, String password, String phone) async {
    _setLoading();
    try {
      final user = await _repo.signUp(name, email.trim(), password, phone);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _repo.signOut();
    _currentUser = null;
    _rememberMe = false;
    _status = AuthStatus.unauthenticated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_savedEmailKey);
    notifyListeners();
  }

  // ── Forgot Password ───────────────────────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    _setLoading();
    try {
      await _repo.sendPasswordResetEmail(email.trim());
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ── Update Profile ────────────────────────────────────────────────────────
  Future<bool> updateProfile(UserModel updated) async {
    _setLoading();
    try {
      final user = await _repo.updateProfile(updated);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.authenticated;
      notifyListeners();
      return false;
    }
  }

  // ── Manage Addresses ──────────────────────────────────────────────────────
  Future<bool> addAddress(AddressModel newAddress) async {
    if (_currentUser == null) return false;
    
    // Nếu đây là địa chỉ đầu tiên hoặc được set default, bỏ default các cái cũ
    List<AddressModel> updatedList = List.from(_currentUser!.addresses);
    bool isFirst = updatedList.isEmpty;
    bool shouldBeDefault = newAddress.isDefault || isFirst;

    if (shouldBeDefault) {
      updatedList = updatedList.map((a) => a.copyWith(isDefault: false)).toList();
    }
    
    final finalAddress = newAddress.copyWith(isDefault: shouldBeDefault);
    updatedList.add(finalAddress);

    return updateProfile(_currentUser!.copyWith(addresses: updatedList));
  }

  Future<bool> updateAddress(AddressModel updatedAddress) async {
    if (_currentUser == null) return false;

    List<AddressModel> updatedList = List.from(_currentUser!.addresses);
    
    if (updatedAddress.isDefault) {
      updatedList = updatedList.map((a) => a.copyWith(isDefault: false)).toList();
    }

    final index = updatedList.indexWhere((a) => a.id == updatedAddress.id);
    if (index >= 0) {
      updatedList[index] = updatedAddress;
      return updateProfile(_currentUser!.copyWith(addresses: updatedList));
    }
    return false;
  }

  Future<bool> setDefaultAddress(String addressId) async {
    if (_currentUser == null) return false;

    List<AddressModel> updatedList = _currentUser!.addresses.map((a) {
      return a.copyWith(isDefault: a.id == addressId);
    }).toList();

    return updateProfile(_currentUser!.copyWith(addresses: updatedList));
  }

  // ── Remember Me ───────────────────────────────────────────────────────────
  void setRememberMe(bool value) {
    _rememberMe = value;
    if (!value) {
      SharedPreferences.getInstance().then((prefs) async {
        await prefs.remove(_rememberMeKey);
        await prefs.remove(_savedEmailKey);
      });
    }
    notifyListeners();
  }

  // ── Saved Email ───────────────────────────────────────────────────────────
  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedEmailKey);
  }

  // ── Clear Error ───────────────────────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }
}
