import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../services/user_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isSeller => _currentUser?.role == UserRole.seller;

  // ── Init: restore session ──
  Future<void> init() async {
    // Don't notify during initialization to avoid "setState during build" error
    _isLoading = true;
    try {
      final userId = UserStorageService.getSessionUserId();
      if (userId != null) {
        _currentUser = UserStorageService.getUserById(userId);
      }
      // Seed demo admin if no users exist
      await _seedDemoAccounts();
    } catch (e) {
      debugPrint('Auth init error: $e');
    }
    _isLoading = false;
    // Defer notification to after build phase
    Future.microtask(() => notifyListeners());
  }

  // ── Demo accounts ──
  Future<void> _seedDemoAccounts() async {
    // Admin account
    if (UserStorageService.getUserByEmail('admin@gamestop.com') == null) {
      final admin = UserModel(
        id: 'admin_001',
        email: 'admin@gamestop.com',
        name: 'GameStop Admin',
        phone: '+1 800 000 0000',
        address: 'GameStop HQ, 625 Westport Pkwy, Grapevine, TX',
        role: UserRole.admin,
      );
      await UserStorageService.saveUser(admin);
      await UserStorageService.saveUserPassword('admin_001', 'admin123');
    }
    // Demo customer
    if (UserStorageService.getUserByEmail('demo@gamestop.com') == null) {
      final demo = UserModel(
        id: 'demo_001',
        email: 'demo@gamestop.com',
        name: 'Demo User',
        phone: '+1 234 567 8900',
        address: '123 Game Street, Gaming City, GC 12345',
        role: UserRole.customer,
      );
      await UserStorageService.saveUser(demo);
      await UserStorageService.saveUserPassword('demo_001', 'password');

      // Welcome notification
      await _addNotification(
        userId: 'demo_001',
        title: 'Welcome to GameStop! 🎮',
        body: 'Your account is ready. Spin the wheel for a welcome coupon!',
        type: NotificationType.system,
      );
    }
  }

  // ────────────────────────────────────────────────────
  // LOGIN
  // ────────────────────────────────────────────────────

  Future<AuthResult> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      if (email.trim().isEmpty || password.isEmpty) {
        return _fail('Please enter your email and password.');
      }

      final user = UserStorageService.getUserByEmail(email.trim());
      if (user == null) {
        return _fail('No account found with this email.');
      }

      if (!UserStorageService.verifyPassword(user.id, password)) {
        return _fail('Incorrect password.');
      }

      _currentUser = user;
      await UserStorageService.saveSession(user.id);

      _setLoading(false);
      notifyListeners();
      return AuthResult.success(user);
    } catch (e) {
      return _fail('Something went wrong. Please try again.');
    }
  }

  // ────────────────────────────────────────────────────
  // REGISTER
  // ────────────────────────────────────────────────────

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
    String? address,
    UserRole role = UserRole.customer,
    String? storeName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Validation
      if (name.trim().isEmpty) return _fail('Name is required.');
      if (email.trim().isEmpty) return _fail('Email is required.');
      if (!email.contains('@') || !email.contains('.')) {
        return _fail('Enter a valid email address.');
      }
      if (password.length < 6) {
        return _fail('Password must be at least 6 characters.');
      }
      if (password != confirmPassword) {
        return _fail('Passwords do not match.');
      }
      if (UserStorageService.getUserByEmail(email.trim()) != null) {
        return _fail('An account with this email already exists.');
      }

      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final user = UserModel(
        id: userId,
        email: email.trim().toLowerCase(),
        name: name.trim(),
        phone: phone?.trim() ?? '',
        address: address?.trim() ?? '',
        role: role,
      );

      await UserStorageService.saveUser(user);
      await UserStorageService.saveUserPassword(userId, password);
      await UserStorageService.saveSession(userId);

      _currentUser = user;

      // Welcome notification
      await _addNotification(
        userId: userId,
        title: 'Welcome to GameStop, ${name.trim()}! 🎮',
        body:
            'Your account is all set. Spin the daily wheel to earn your first coupon!',
        type: NotificationType.system,
      );

      _setLoading(false);
      notifyListeners();
      return AuthResult.success(user);
    } catch (e) {
      return _fail('Registration failed. Please try again.');
    }
  }

  // ────────────────────────────────────────────────────
  // LOGOUT
  // ────────────────────────────────────────────────────

  Future<void> logout() async {
    _setLoading(true);
    await UserStorageService.clearSession();
    _currentUser = null;
    _setLoading(false);
    notifyListeners();
  }

  // ────────────────────────────────────────────────────
  // UPDATE PROFILE
  // ────────────────────────────────────────────────────

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_currentUser == null) return false;
    _currentUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      address: address,
    );
    await UserStorageService.saveUser(_currentUser!);
    notifyListeners();
    return true;
  }

  Future<bool> updatePreferences(UserPreferences prefs) async {
    if (_currentUser == null) return false;
    _currentUser = _currentUser!.copyWith(preferences: prefs);
    await UserStorageService.saveUser(_currentUser!);
    notifyListeners();
    return true;
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;
    if (!UserStorageService.verifyPassword(_currentUser!.id, currentPassword)) {
      _errorMessage = 'Current password is incorrect.';
      notifyListeners();
      return false;
    }
    await UserStorageService.saveUserPassword(_currentUser!.id, newPassword);
    return true;
  }

  // ────────────────────────────────────────────────────
  // NOTIFICATIONS  (for current user)
  // ────────────────────────────────────────────────────

  List<AppNotification> getNotifications() {
    if (_currentUser == null) return [];
    return UserStorageService.loadNotifications(_currentUser!.id);
  }

  int get unreadNotificationCount {
    return getNotifications().where((n) => !n.isRead).length;
  }

  Future<void> markNotificationRead(String notifId) async {
    if (_currentUser == null) return;
    final notifs = getNotifications();
    final updated = notifs
        .map((n) => n.id == notifId ? n.copyWith(isRead: true) : n)
        .toList();
    await UserStorageService.saveNotifications(_currentUser!.id, updated);
    notifyListeners();
  }

  Future<void> markAllNotificationsRead() async {
    if (_currentUser == null) return;
    final notifs =
        getNotifications().map((n) => n.copyWith(isRead: true)).toList();
    await UserStorageService.saveNotifications(_currentUser!.id, notifs);
    notifyListeners();
  }

  Future<void> _addNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? metadata,
  }) async {
    final notif = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      body: body,
      type: type,
      metadata: metadata,
    );
    final existing = UserStorageService.loadNotifications(userId);
    existing.insert(0, notif);
    await UserStorageService.saveNotifications(userId, existing);
  }

  /// Push a notification to any user (used by admin actions)
  Future<void> pushNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? metadata,
  }) async {
    await _addNotification(
        userId: userId,
        title: title,
        body: body,
        type: type,
        metadata: metadata);
    // If this is the current user, refresh UI
    if (_currentUser?.id == userId) notifyListeners();
  }

  // ────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────

  AuthResult _fail(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
    return AuthResult.failure(message);
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() => _clearError();
}

class AuthResult {
  final bool success;
  final String? error;
  final UserModel? user;

  AuthResult._({required this.success, this.error, this.user});

  factory AuthResult.success(UserModel user) =>
      AuthResult._(success: true, user: user);

  factory AuthResult.failure(String error) =>
      AuthResult._(success: false, error: error);
}
