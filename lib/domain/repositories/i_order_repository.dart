import '../models/order_model.dart';
import '../models/audit_log_model.dart';

abstract class IOrderRepository {
  Stream<List<OrderModel>> getOrdersStream();
  Future<List<OrderModel>> getOrders();
  Future<OrderModel?> getOrderById(String id);
  Future<void> addOrder(OrderModel order);
  Future<void> updateOrder(OrderModel order);
  Future<void> deleteOrder(String id);
  Future<void> importOrders(List<OrderModel> orders);
  Stream<List<AuditLogModel>> getAuditLogsStream();
  Future<List<String>> getUniqueVehicles();
  Future<List<String>> getUniqueCustomers();
  Future<List<String>> getUniqueLocations();
}
