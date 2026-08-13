import '../../domain/models/order_model.dart';
import '../../core/constants/app_constants.dart';

class ExcelSeedData {
  static List<OrderModel> getInitialOrders() {
    return [
      ..._getAugustOrders(),

    ];
  }


  static List<OrderModel> _getAugustOrders() {
    return [
      _create(293, DateTime(2026, 8, 6), 'GJ-05-0000', 'PSM', 'ADITYA INFRA', 'GGBS', 33.52, null, 'PNJ'),
      _create(292, DateTime(2026, 8, 6), 'GJ-05-0000', 'UKAI', 'CEMECH SOLUTIONS LLP', 'FLYASH', 32.86, 32.86, 'UMIYA'),
      _create(291, DateTime(2026, 8, 6), 'GJ-05-0080', 'UKAI', 'JUST BUILDTECH', 'FLYASH', 27.56, 27.56, 'UMIYA'),
    ];
  }



  static OrderModel _create(
    int index,
    DateTime date,
    String vehicle,
    String from,
    String to,
    String material,
    double qty,
    double? netUkai,
    String company, {
    int? payDays,
    DateTime? payDate,
    String? remarks,
  }) {
    final status = (netUkai != null || company == 'UMIYA')
        ? AppConstants.statusCompleted
        : (material == 'CEMENT' ? AppConstants.statusDelivered : AppConstants.statusInTransit);

    return OrderModel(
      id: 'ORD-${index.toString().padLeft(3, '0')}',
      date: date,
      vehicleNumber: vehicle,
      fromLocation: from,
      toLocation: to,
      material: material,
      quantity: qty,
      netWeightUkai: netUkai,
      company: company,
      paymentDays: payDays,
      paymentDate: payDate,
      remarks: remarks,
      status: status,
      createdBy: 'Admin',
      createdAt: date,
      updatedAt: date,
    );
  }
}
