class AppConstants {
  static const String appTitle = 'business name';
  static const String appSubtitle = 'Order & Trip Management System';

  // Companies
  static const String companyUmiya = 'name name';
  static const String companyPnj = 'name';
  static const List<String> companies = [companyUmiya, companyPnj];

  // Materials
  static const String materialFlyAsh = 'FLYASH';
  static const String materialGGBS = 'GGBS';
  static const String materialCement = 'CEMENT';
  static const List<String> materials = [materialFlyAsh, materialGGBS, materialCement];

  // Order Statuses
  static const String statusPending = 'Pending';
  static const String statusInTransit = 'In Transit';
  static const String statusDelivered = 'Delivered';
  static const String statusCompleted = 'Completed';
  static const List<String> orderStatuses = [
    statusPending,
    statusInTransit,
    statusDelivered,
    statusCompleted,
  ];

  // Expense Categories
  static const List<String> expenseCategories = [
    'Diesel (Litre)',
    'Diesel (Rupees)',
    'Adblue',
    'Electric work',
    'Compressor work',
    'Mechanical work',
    'Tank clean',
    'Miscellaneous',
  ];

  // Demo Admin Credentials
  static const String defaultAdminEmail = 'admin.com';
  static const String defaultAdminPassword = 'admin123';
}






// ------------- old code version --------------

// class AppConstants {
//   static const String appTitle = 'business name';
//   static const String appSubtitle = 'Order & Trip Management System';

//   // Companies
//   static const String companyUmiya = 'name';
//   static const String companyPnj = 'name';
//   static const List<String> companies = [companyUmiya, companyPnj];

//   // Materials
//   static const String materialFlyAsh = 'FLYASH';
//   static const String materialGGBS = 'GGBS';
//   static const String materialCement = 'CEMENT';
//   static const List<String> materials = [materialFlyAsh, materialGGBS, materialCement];

//   // Order Statuses
//   static const String statusPending = 'Pending';
//   static const String statusInTransit = 'In Transit';
//   static const String statusDelivered = 'Delivered';
//   static const String statusCompleted = 'Completed';
//   static const List<String> orderStatuses = [
//     statusPending,
//     statusInTransit,
//     statusDelivered,
//     statusCompleted,
//   ];

//   // Demo Admin Credentials
//   static const String defaultAdminEmail = 'admin.com';
//   static const String defaultAdminPassword = 'admin123';
// }
