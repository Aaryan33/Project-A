class TripAttachment {
  final String name;
  final String path;
  final String size;

  TripAttachment({
    required this.name,
    required this.path,
    required this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'path': path,
      'size': size,
    };
  }

  factory TripAttachment.fromMap(Map<String, dynamic> map) {
    return TripAttachment(
      name: map['name'] ?? '',
      path: map['path'] ?? '',
      size: map['size'] ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final DateTime date;
  final String vehicleNumber;
  final String fromLocation;
  final String toLocation;
  final String material;
  final double quantity;
  final double? netWeightUkai;
  final String company;
  final String? remarks;
  final String? expenses;
  final Map<String, double> expenseBreakdown;
  final int? paymentDays;
  final DateTime? paymentDate;
  final String? attachmentPath;
  final String? attachmentName;
  final String? attachmentSize;
  final List<TripAttachment> attachments;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> customFields;

  OrderModel({
    required this.id,
    required this.date,
    required this.vehicleNumber,
    required this.fromLocation,
    required this.toLocation,
    required this.material,
    required this.quantity,
    this.netWeightUkai,
    required this.company,
    this.remarks,
    this.expenses,
    this.expenseBreakdown = const {},
    this.paymentDays,
    this.paymentDate,
    this.attachmentPath,
    this.attachmentName,
    this.attachmentSize,
    this.attachments = const [],
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.customFields = const {},
  });

  List<TripAttachment> get allAttachments {
    if (attachments.isNotEmpty) return attachments;
    if (attachmentName != null && attachmentName!.isNotEmpty) {
      return [
        TripAttachment(
          name: attachmentName!,
          path: attachmentPath ?? '',
          size: attachmentSize ?? 'Digital Attachment',
        )
      ];
    }
    return [];
  }

  double get totalExpense {
    if (expenseBreakdown.isEmpty) return 0.0;
    double sum = 0.0;
    expenseBreakdown.forEach((key, val) {
      if (key != 'Diesel (Litre)') {
        sum += val;
      }
    });
    return sum;
  }

  OrderModel copyWith({
    String? id,
    DateTime? date,
    String? vehicleNumber,
    String? fromLocation,
    String? toLocation,
    String? material,
    double? quantity,
    double? netWeightUkai,
    String? company,
    String? remarks,
    String? expenses,
    Map<String, double>? expenseBreakdown,
    int? paymentDays,
    DateTime? paymentDate,
    String? attachmentPath,
    String? attachmentName,
    String? attachmentSize,
    List<TripAttachment>? attachments,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customFields,
  }) {
    return OrderModel(
      id: id ?? this.id,
      date: date ?? this.date,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      material: material ?? this.material,
      quantity: quantity ?? this.quantity,
      netWeightUkai: netWeightUkai ?? this.netWeightUkai,
      company: company ?? this.company,
      remarks: remarks ?? this.remarks,
      expenses: expenses ?? this.expenses,
      expenseBreakdown: expenseBreakdown ?? this.expenseBreakdown,
      paymentDays: paymentDays ?? this.paymentDays,
      paymentDate: paymentDate ?? this.paymentDate,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customFields: customFields ?? this.customFields,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'vehicleNumber': vehicleNumber,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'material': material,
      'quantity': quantity,
      'netWeightUkai': netWeightUkai,
      'company': company,
      'remarks': remarks,
      'expenses': expenses,
      'expenseBreakdown': expenseBreakdown,
      'paymentDays': paymentDays,
      'paymentDate': paymentDate?.toIso8601String(),
      'attachmentPath': attachmentPath,
      'attachmentName': attachmentName,
      'attachmentSize': attachmentSize,
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'customFields': customFields,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    Map<String, double> parsedExpenses = {};
    if (map['expenseBreakdown'] != null) {
      final rawMap = Map<String, dynamic>.from(map['expenseBreakdown']);
      rawMap.forEach((key, value) {
        if (value is num) parsedExpenses[key] = value.toDouble();
      });
    }

    List<TripAttachment> parsedAttachments = [];
    if (map['attachments'] != null) {
      final list = List<dynamic>.from(map['attachments']);
      parsedAttachments = list.map((item) => TripAttachment.fromMap(Map<String, dynamic>.from(item))).toList();
    }

    return OrderModel(
      id: id,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      vehicleNumber: map['vehicleNumber'] ?? '',
      fromLocation: map['fromLocation'] ?? '',
      toLocation: map['toLocation'] ?? '',
      material: map['material'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      netWeightUkai: (map['netWeightUkai'] as num?)?.toDouble(),
      company: map['company'] ?? 'UMIYA',
      remarks: map['remarks'],
      expenses: map['expenses'],
      expenseBreakdown: parsedExpenses,
      paymentDays: map['paymentDays'] as int?,
      paymentDate: map['paymentDate'] != null ? DateTime.tryParse(map['paymentDate']) : null,
      attachmentPath: map['attachmentPath'],
      attachmentName: map['attachmentName'],
      attachmentSize: map['attachmentSize'],
      attachments: parsedAttachments,
      status: map['status'] ?? 'Completed',
      createdBy: map['createdBy'] ?? 'Admin',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      customFields: Map<String, dynamic>.from(map['customFields'] ?? {}),
    );
  }
}











// ----------- previous code ---------------

// class OrderModel {
//   final String id;
//   final DateTime date;
//   final String vehicleNumber;
//   final String fromLocation;
//   final String toLocation;
//   final String material;
//   final double quantity;
//   final double? netWeightUkai;
//   final String company;
//   final String? remarks;
//   final String? expenses;
//   final int? paymentDays;
//   final DateTime? paymentDate;
//   final String? attachmentPath;
//   final String? attachmentName;
//   final String? attachmentSize;
//   final String status;
//   final String createdBy;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final Map<String, dynamic> customFields;

//   OrderModel({
//     required this.id,
//     required this.date,
//     required this.vehicleNumber,
//     required this.fromLocation,
//     required this.toLocation,
//     required this.material,
//     required this.quantity,
//     this.netWeightUkai,
//     required this.company,
//     this.remarks,
//     this.expenses,
//     this.paymentDays,
//     this.paymentDate,
//     this.attachmentPath,
//     this.attachmentName,
//     this.attachmentSize,
//     required this.status,
//     required this.createdBy,
//     required this.createdAt,
//     required this.updatedAt,
//     this.customFields = const {},
//   });

//   OrderModel copyWith({
//     String? id,
//     DateTime? date,
//     String? vehicleNumber,
//     String? fromLocation,
//     String? toLocation,
//     String? material,
//     double? quantity,
//     double? netWeightUkai,
//     String? company,
//     String? remarks,
//     String? expenses,
//     int? paymentDays,
//     DateTime? paymentDate,
//     String? attachmentPath,
//     String? attachmentName,
//     String? attachmentSize,
//     String? status,
//     String? createdBy,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     Map<String, dynamic>? customFields,
//   }) {
//     return OrderModel(
//       id: id ?? this.id,
//       date: date ?? this.date,
//       vehicleNumber: vehicleNumber ?? this.vehicleNumber,
//       fromLocation: fromLocation ?? this.fromLocation,
//       toLocation: toLocation ?? this.toLocation,
//       material: material ?? this.material,
//       quantity: quantity ?? this.quantity,
//       netWeightUkai: netWeightUkai ?? this.netWeightUkai,
//       company: company ?? this.company,
//       remarks: remarks ?? this.remarks,
//       expenses: expenses ?? this.expenses,
//       paymentDays: paymentDays ?? this.paymentDays,
//       paymentDate: paymentDate ?? this.paymentDate,
//       attachmentPath: attachmentPath ?? this.attachmentPath,
//       attachmentName: attachmentName ?? this.attachmentName,
//       attachmentSize: attachmentSize ?? this.attachmentSize,
//       status: status ?? this.status,
//       createdBy: createdBy ?? this.createdBy,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       customFields: customFields ?? this.customFields,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'date': date.toIso8601String(),
//       'vehicleNumber': vehicleNumber,
//       'fromLocation': fromLocation,
//       'toLocation': toLocation,
//       'material': material,
//       'quantity': quantity,
//       'netWeightUkai': netWeightUkai,
//       'company': company,
//       'remarks': remarks,
//       'expenses': expenses,
//       'paymentDays': paymentDays,
//       'paymentDate': paymentDate?.toIso8601String(),
//       'attachmentPath': attachmentPath,
//       'attachmentName': attachmentName,
//       'attachmentSize': attachmentSize,
//       'status': status,
//       'createdBy': createdBy,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//       'customFields': customFields,
//     };
//   }

//   factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
//     return OrderModel(
//       id: id,
//       date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
//       vehicleNumber: map['vehicleNumber'] ?? '',
//       fromLocation: map['fromLocation'] ?? '',
//       toLocation: map['toLocation'] ?? '',
//       material: map['material'] ?? '',
//       quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
//       netWeightUkai: (map['netWeightUkai'] as num?)?.toDouble(),
//       company: map['company'] ?? 'UMIYA',
//       remarks: map['remarks'],
//       expenses: map['expenses'],
//       paymentDays: map['paymentDays'] as int?,
//       paymentDate: map['paymentDate'] != null ? DateTime.tryParse(map['paymentDate']) : null,
//       attachmentPath: map['attachmentPath'],
//       attachmentName: map['attachmentName'],
//       attachmentSize: map['attachmentSize'],
//       status: map['status'] ?? 'Completed',
//       createdBy: map['createdBy'] ?? 'Admin',
//       createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
//       updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
//       customFields: Map<String, dynamic>.from(map['customFields'] ?? {}),
//     );
//   }
// }
