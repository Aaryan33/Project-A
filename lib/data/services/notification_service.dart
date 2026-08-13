import 'dart:async';
import '../../domain/models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _controller = StreamController<List<NotificationModel>>.broadcast();
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'NOTIF-1',
      title: 'New Order Added',
      body: 'Vehicle GJ05AB1234 | Fly Ash: 30.25 MT -> ABC Construction',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
      type: 'order_created',
    ),
    NotificationModel(
      id: 'NOTIF-2',
      title: 'Order Status Updated',
      body: 'Vehicle GJ058082 | Cement trip marked as Delivered',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      type: 'order_updated',
    ),
  ];

  Stream<List<NotificationModel>> get notificationsStream async* {
    yield List.unmodifiable(_notifications);
    yield* _controller.stream;
  }

  List<NotificationModel> get currentNotifications => List.unmodifiable(_notifications);

  void initialize() {
    _controller.add(_notifications);
  }

  void notifyOrderCreated({
    required String vehicleNumber,
    required String material,
    required double quantity,
    required String destination,
    required String orderId,
  }) {
    final notif = NotificationModel(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Order Added',
      body: 'Vehicle $vehicleNumber | Material: $material | Qty: ${quantity.toStringAsFixed(2)} MT | Destination: $destination',
      timestamp: DateTime.now(),
      isRead: false,
      orderId: orderId,
      type: 'order_created',
    );

    _notifications.insert(0, notif);
    _controller.add(_notifications);
  }

  void notifyOrderUpdated({required String vehicleNumber, required String orderId}) {
    final notif = NotificationModel(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Order Details Updated',
      body: 'Vehicle $vehicleNumber details were modified by Admin.',
      timestamp: DateTime.now(),
      isRead: false,
      orderId: orderId,
      type: 'order_updated',
    );

    _notifications.insert(0, notif);
    _controller.add(_notifications);
  }

  void markAsRead(String notifId) {
    final index = _notifications.indexWhere((n) => n.id == notifId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _controller.add(_notifications);
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _controller.add(_notifications);
  }

  void deleteNotification(String notifId) {
    _notifications.removeWhere((n) => n.id == notifId);
    _controller.add(_notifications);
  }
}
