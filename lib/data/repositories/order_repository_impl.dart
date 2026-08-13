import 'dart:async';
import 'package:hive/hive.dart';
import '../../domain/models/order_model.dart';
import '../../domain/models/audit_log_model.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../seed/excel_seed_data.dart';
import '../services/notification_service.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final _ordersStreamController = StreamController<List<OrderModel>>.broadcast();
  final _auditLogsStreamController = StreamController<List<AuditLogModel>>.broadcast();

  final List<OrderModel> _orders = [];
  final List<AuditLogModel> _auditLogs = [];

  OrderRepositoryImpl() {
    _initRepository();
  }

  void _initRepository() {
    // Populate with seed records from user's Excel sheet
    _orders.addAll(ExcelSeedData.getInitialOrders());

    _auditLogs.add(
      AuditLogModel(
        id: 'LOG-1',
        action: 'System Seed',
        adminName: 'System',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        orderId: 'ORD-001',
        vehicleNumber: 'GJ-05-4500',
        details: 'Initial Excel records loaded into Firestore database.',
      ),
    );

    _emitOrders();
    _emitAuditLogs();
  }

  void _emitOrders() {
    _ordersStreamController.add(List.unmodifiable(_orders));
  }

  void _emitAuditLogs() {
    _auditLogsStreamController.add(List.unmodifiable(_auditLogs));
  }

  @override
  Stream<List<OrderModel>> getOrdersStream() async* {
    yield List.unmodifiable(_orders);
    yield* _ordersStreamController.stream;
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    return List.unmodifiable(_orders);
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addOrder(OrderModel order) async {
    _orders.insert(0, order);
    _emitOrders();

    _auditLogs.insert(
      0,
      AuditLogModel(
        id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
        action: 'Created',
        adminName: order.createdBy,
        timestamp: DateTime.now(),
        orderId: order.id,
        vehicleNumber: order.vehicleNumber,
        details: 'Created order for ${order.material} (${order.quantity} MT) to ${order.toLocation}',
      ),
    );
    _emitAuditLogs();

    NotificationService().notifyOrderCreated(
      vehicleNumber: order.vehicleNumber,
      material: order.material,
      quantity: order.quantity,
      destination: order.toLocation,
      orderId: order.id,
    );
  }

  @override
  Future<void> updateOrder(OrderModel order) async {
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _orders[index] = order;
      _emitOrders();

      _auditLogs.insert(
        0,
        AuditLogModel(
          id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
          action: 'Updated',
          adminName: order.createdBy,
          timestamp: DateTime.now(),
          orderId: order.id,
          vehicleNumber: order.vehicleNumber,
          details: 'Updated details for vehicle ${order.vehicleNumber}. Status: ${order.status}',
        ),
      );
      _emitAuditLogs();

      NotificationService().notifyOrderUpdated(
        vehicleNumber: order.vehicleNumber,
        orderId: order.id,
      );
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      final removed = _orders.removeAt(index);
      _emitOrders();

      _auditLogs.insert(
        0,
        AuditLogModel(
          id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
          action: 'Deleted',
          adminName: 'Admin',
          timestamp: DateTime.now(),
          orderId: id,
          vehicleNumber: removed.vehicleNumber,
          details: 'Deleted trip order ${removed.id} for vehicle ${removed.vehicleNumber}',
        ),
      );
      _emitAuditLogs();
    }
  }

  @override
  Future<void> importOrders(List<OrderModel> importedOrders) async {
    for (var o in importedOrders) {
      final exists = _orders.any((existing) =>
          existing.vehicleNumber == o.vehicleNumber &&
          existing.date.year == o.date.year &&
          existing.date.month == o.date.month &&
          existing.date.day == o.date.day &&
          existing.toLocation.toLowerCase() == o.toLocation.toLowerCase());
      if (!exists) {
        _orders.insert(0, o);
      }
    }
    _emitOrders();

    _auditLogs.insert(
      0,
      AuditLogModel(
        id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
        action: 'Imported',
        adminName: 'Admin',
        timestamp: DateTime.now(),
        orderId: 'BULK',
        vehicleNumber: 'MULTIPLE',
        details: 'Imported ${importedOrders.length} records from Excel file.',
      ),
    );
    _emitAuditLogs();
  }

  @override
  Stream<List<AuditLogModel>> getAuditLogsStream() async* {
    yield List.unmodifiable(_auditLogs);
    yield* _auditLogsStreamController.stream;
  }

  @override
  Future<List<String>> getUniqueVehicles() async {
    final set = _orders.map((o) => o.vehicleNumber).where((v) => v.isNotEmpty).toSet();
    return set.toList()..sort();
  }

  @override
  Future<List<String>> getUniqueCustomers() async {
    final set = _orders.map((o) => o.toLocation).where((c) => c.isNotEmpty).toSet();
    return set.toList()..sort();
  }

  @override
  Future<List<String>> getUniqueLocations() async {
    final set = _orders.map((o) => o.fromLocation).where((l) => l.isNotEmpty).toSet();
    return set.toList()..sort();
  }
}
