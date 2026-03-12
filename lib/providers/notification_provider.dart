import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/user_storage_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  String? _userId;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  Future<void> loadForUser(String userId) async {
    _userId = userId;
    _notifications = UserStorageService.loadNotifications(userId);
    notifyListeners();
  }

  void clearForLogout() {
    _notifications = [];
    _userId = null;
    notifyListeners();
  }

  Future<void> markRead(String notifId) async {
    if (_userId == null) return;
    _notifications = _notifications
        .map((n) => n.id == notifId ? n.copyWith(isRead: true) : n)
        .toList();
    await UserStorageService.saveNotifications(_userId!, _notifications);
    notifyListeners();
  }

  Future<void> markAllRead() async {
    if (_userId == null) return;
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await UserStorageService.saveNotifications(_userId!, _notifications);
    notifyListeners();
  }

  Future<void> addNotification(AppNotification notif) async {
    if (_userId == null) return;
    _notifications.insert(0, notif);
    await UserStorageService.saveNotifications(_userId!, _notifications);
    notifyListeners();
  }

  Future<void> deleteNotification(String notifId) async {
    if (_userId == null) return;
    _notifications.removeWhere((n) => n.id == notifId);
    await UserStorageService.saveNotifications(_userId!, _notifications);
    notifyListeners();
  }
}