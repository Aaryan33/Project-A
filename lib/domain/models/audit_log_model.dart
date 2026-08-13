class AuditLogModel {
  final String id;
  final String action; // 'Created', 'Updated', 'Deleted'
  final String adminName;
  final DateTime timestamp;
  final String orderId;
  final String vehicleNumber;
  final String details;

  AuditLogModel({
    required this.id,
    required this.action,
    required this.adminName,
    required this.timestamp,
    required this.orderId,
    required this.vehicleNumber,
    required this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'adminName': adminName,
      'timestamp': timestamp.toIso8601String(),
      'orderId': orderId,
      'vehicleNumber': vehicleNumber,
      'details': details,
    };
  }

  factory AuditLogModel.fromMap(Map<String, dynamic> map, String id) {
    return AuditLogModel(
      id: id,
      action: map['action'] ?? 'Action',
      adminName: map['adminName'] ?? 'Admin',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      orderId: map['orderId'] ?? '',
      vehicleNumber: map['vehicleNumber'] ?? '',
      details: map['details'] ?? '',
    );
  }
}
