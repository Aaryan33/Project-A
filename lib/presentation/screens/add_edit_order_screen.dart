import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/models/order_model.dart';
import '../providers/order_providers.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';

class AddEditOrderScreen extends ConsumerStatefulWidget {
  final String? orderId;

  const AddEditOrderScreen({super.key, this.orderId});

  @override
  ConsumerState<AddEditOrderScreen> createState() => _AddEditOrderScreenState();
}

class _AddEditOrderScreenState extends ConsumerState<AddEditOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  final _vehicleController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  String _selectedMaterial = AppConstants.materialFlyAsh;
  final _quantityController = TextEditingController();
  final _netWeightUkaiController = TextEditingController();
  final _expensesController = TextEditingController();
  String _selectedCompany = AppConstants.companyUmiya;
  String _selectedStatus = AppConstants.statusCompleted;

  // Attachment fields
  String? _attachmentPath;
  String? _attachmentName;
  String? _attachmentSize;

  bool _isEditing = false;
  bool _isLoading = false;

  // Custom input toggles
  bool _isCustomVehicle = false;
  bool _isCustomCustomer = false;
  bool _isCustomLocation = false;

  List<String> _vehicleSuggestions = [];
  List<String> _customerSuggestions = [];
  List<String> _locationSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadMasters();
    if (widget.orderId != null && widget.orderId!.isNotEmpty) {
      _isEditing = true;
      _populateExistingData();
    }
  }

  Future<void> _loadMasters() async {
    final repo = ref.read(orderRepositoryProvider);
    final vehicles = await repo.getUniqueVehicles();
    final customers = await repo.getUniqueCustomers();
    final locations = await repo.getUniqueLocations();

    setState(() {
      _vehicleSuggestions = vehicles;
      _customerSuggestions = customers;
      _locationSuggestions = locations;
    });
  }

  void _populateExistingData() async {
    final repo = ref.read(orderRepositoryProvider);
    final existing = await repo.getOrderById(widget.orderId!);
    if (existing != null) {
      setState(() {
        _selectedDate = existing.date;
        _vehicleController.text = existing.vehicleNumber;
        _fromController.text = existing.fromLocation;
        _toController.text = existing.toLocation;
        _selectedMaterial = existing.material;
        _quantityController.text = existing.quantity.toString();
        _netWeightUkaiController.text = existing.netWeightUkai?.toString() ?? '';
        _expensesController.text = existing.expenses ?? '';
        _selectedCompany = existing.company;
        _selectedStatus = existing.status;
        _attachmentPath = existing.attachmentPath;
        _attachmentName = existing.attachmentName;
        _attachmentSize = existing.attachmentSize;

        // Auto-enable custom text mode if value is not in suggestions list
        if (!_vehicleSuggestions.contains(existing.vehicleNumber) && existing.vehicleNumber.isNotEmpty) {
          _isCustomVehicle = true;
        }
        if (!_customerSuggestions.contains(existing.toLocation) && existing.toLocation.isNotEmpty) {
          _isCustomCustomer = true;
        }
        if (!_locationSuggestions.contains(existing.fromLocation) && existing.fromLocation.isNotEmpty) {
          _isCustomLocation = true;
        }
      });
    }
  }

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final sizeKb = (file.size / 1024).toStringAsFixed(1);

        setState(() {
          _attachmentPath = file.path;
          _attachmentName = file.name;
          _attachmentSize = '$sizeKb KB';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  InputDecoration _compactDecoration({
    required String labelText,
    String? hintText,
    required IconData prefixIcon,
    Color iconColor = AppColors.accentOrange,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      prefixIcon: Icon(prefixIcon, color: iconColor, size: 18),
      labelStyle: const TextStyle(fontSize: 12),
      hintStyle: const TextStyle(fontSize: 11),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Trip Order' : 'Add New Order',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: TRIP IDENTIFICATION & DATE
                _buildSectionHeader('TRIP IDENTIFICATION & DATE'),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: _compactDecoration(
                            labelText: 'Trip Date',
                            prefixIcon: Icons.calendar_month_rounded,
                          ),
                          child: Text(
                            DateFormatter.formatDate(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCompany,
                        isExpanded: true,
                        decoration: _compactDecoration(
                          labelText: 'Company Tag',
                          prefixIcon: Icons.business_rounded,
                          iconColor: AppColors.royalBlue,
                        ),
                        items: AppConstants.companies.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCompany = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // SECTION 2: VEHICLE & ROUTE DETAILS
                _buildSectionHeader('VEHICLE & ROUTE DETAILS'),
                // Row 2: Material | To Customer Dropdown
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedMaterial,
                        isExpanded: true,
                        decoration: _compactDecoration(
                          labelText: 'Material',
                          prefixIcon: Icons.category_rounded,
                        ),
                        items: AppConstants.materials.map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(m, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMaterial = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: !_isCustomCustomer
                          ? DropdownButtonFormField<String>(
                              value: _customerSuggestions.contains(_toController.text) ? _toController.text : null,
                              isExpanded: true,
                              decoration: _compactDecoration(
                                labelText: 'To Customer',
                                hintText: 'Select or add customer',
                                prefixIcon: Icons.place_rounded,
                              ),
                              items: [
                                ..._customerSuggestions.map((c) {
                                  return DropdownMenuItem<String>(
                                    value: c,
                                    child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis),
                                  );
                                }),
                                const DropdownMenuItem<String>(
                                  value: '__ADD_NEW_CUSTOMER__',
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_circle_outline_rounded, size: 14, color: AppColors.accentOrange),
                                      SizedBox(width: 4),
                                      Text(
                                        '+ Add New Customer',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.accentOrange),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val == '__ADD_NEW_CUSTOMER__') {
                                  setState(() {
                                    _isCustomCustomer = true;
                                    _toController.clear();
                                  });
                                } else if (val != null) {
                                  setState(() {
                                    _toController.text = val;
                                  });
                                }
                              },
                              validator: (val) => _toController.text.trim().isEmpty ? 'Destination required' : null,
                            )
                          : TextFormField(
                              controller: _toController,
                              autofocus: true,
                              decoration: _compactDecoration(
                                labelText: 'New Customer Name',
                                hintText: 'Enter customer name',
                                prefixIcon: Icons.place_rounded,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.list_rounded, size: 16),
                                  onPressed: () => setState(() => _isCustomCustomer = false),
                                  tooltip: 'Select from list',
                                ),
                              ),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Destination required' : null,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 3: From Location Dropdown | Quantity (MT)
                Row(
                  children: [
                    Expanded(
                      child: !_isCustomLocation
                          ? DropdownButtonFormField<String>(
                              value: _locationSuggestions.contains(_fromController.text) ? _fromController.text : null,
                              isExpanded: true,
                              decoration: _compactDecoration(
                                labelText: 'From Location',
                                hintText: 'Select or add source',
                                prefixIcon: Icons.location_on_outlined,
                              ),
                              items: [
                                ..._locationSuggestions.map((l) {
                                  return DropdownMenuItem<String>(
                                    value: l,
                                    child: Text(l, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis),
                                  );
                                }),
                                const DropdownMenuItem<String>(
                                  value: '__ADD_NEW_LOCATION__',
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_circle_outline_rounded, size: 14, color: AppColors.accentOrange),
                                      SizedBox(width: 4),
                                      Text(
                                        '+ Add New Location',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.accentOrange),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val == '__ADD_NEW_LOCATION__') {
                                  setState(() {
                                    _isCustomLocation = true;
                                    _fromController.clear();
                                  });
                                } else if (val != null) {
                                  setState(() {
                                    _fromController.text = val;
                                  });
                                }
                              },
                              validator: (val) => _fromController.text.trim().isEmpty ? 'Source required' : null,
                            )
                          : TextFormField(
                              controller: _fromController,
                              autofocus: true,
                              decoration: _compactDecoration(
                                labelText: 'New Source Location',
                                hintText: 'Enter location name',
                                prefixIcon: Icons.location_on_outlined,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.list_rounded, size: 16),
                                  onPressed: () => setState(() => _isCustomLocation = false),
                                  tooltip: 'Select from list',
                                ),
                              ),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Source required' : null,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _compactDecoration(
                          labelText: 'Quantity (MT)',
                          hintText: 'e.g. 28.50',
                          prefixIcon: Icons.scale_rounded,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter quantity';
                          if (double.tryParse(val) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 4: Vehicle Number (Dropdown of previously used vehicles + Option to Add New Vehicle Number)
                if (!_isCustomVehicle)
                  DropdownButtonFormField<String>(
                    value: _vehicleSuggestions.contains(_vehicleController.text) ? _vehicleController.text : null,
                    isExpanded: true,
                    decoration: _compactDecoration(
                      labelText: 'Vehicle Number',
                      hintText: 'Select or add vehicle number',
                      prefixIcon: Icons.directions_bus_rounded,
                    ),
                    items: [
                      ..._vehicleSuggestions.map((v) {
                        return DropdownMenuItem<String>(
                          value: v,
                          child: Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        );
                      }),
                      const DropdownMenuItem<String>(
                        value: '__ADD_NEW_VEHICLE__',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline_rounded, size: 14, color: AppColors.accentOrange),
                            SizedBox(width: 6),
                            Text(
                              '+ Add New Vehicle Number',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentOrange),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == '__ADD_NEW_VEHICLE__') {
                        setState(() {
                          _isCustomVehicle = true;
                          _vehicleController.clear();
                        });
                      } else if (val != null) {
                        setState(() {
                          _vehicleController.text = val;
                        });
                      }
                    },
                    validator: (val) => _vehicleController.text.trim().isEmpty ? 'Please select or enter vehicle number' : null,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _vehicleController,
                          autofocus: true,
                          decoration: _compactDecoration(
                            labelText: 'New Vehicle Number',
                            hintText: 'e.g. GJ-05-4500',
                            prefixIcon: Icons.directions_bus_rounded,
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Enter vehicle number' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                const SizedBox(height: 10),

                // SECTION 3: WEIGHT & STATUS
                _buildSectionHeader('WEIGHT & STATUS'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _netWeightUkaiController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _compactDecoration(
                          labelText: 'Net Weight (Ukai)',
                          hintText: 'Ukai weight',
                          prefixIcon: Icons.balance_rounded,
                          iconColor: AppColors.royalBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        decoration: _compactDecoration(
                          labelText: 'Trip Status',
                          prefixIcon: Icons.verified_rounded,
                          iconColor: AppColors.statusDelivered,
                        ),
                        items: AppConstants.orderStatuses.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStatus = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // SECTION 4: TRIP EXPENSE DETAILS
                _buildSectionHeader('TRIP EXPENSE DETAILS'),
                TextFormField(
                  controller: _expensesController,
                  maxLines: 2,
                  decoration: _compactDecoration(
                    labelText: 'Trip Expenses',
                    hintText: 'e.g. Diesel: ₹4500, Toll: ₹350, Allowance: ₹500',
                    prefixIcon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(height: 10),

                // SECTION 5: WEIGHBRIDGE SLIP ATTACHMENT (PDF, JPG, PNG)
                _buildSectionHeader('WEIGHBRIDGE SLIP ATTACHMENT'),
                if (_attachmentName == null)
                  OutlinedButton.icon(
                    onPressed: _pickAttachment,
                    icon: const Icon(Icons.attach_file_rounded, size: 18, color: AppColors.accentOrange),
                    label: const Text(
                      'Upload Weighbridge Slip (PDF / JPG / PNG)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentOrange),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 42),
                      side: BorderSide(color: AppColors.accentOrange.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.royalBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.royalBlue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _attachmentName!.endsWith('.pdf') ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                          color: AppColors.royalBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _attachmentName!,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_attachmentSize != null)
                                Text(
                                  _attachmentSize!,
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _attachmentPath = null;
                              _attachmentName = null;
                              _attachmentSize = null;
                            });
                          },
                          tooltip: 'Remove Attachment',
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Save Order Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isEditing ? 'UPDATE ORDER' : 'SAVE ORDER',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.6),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 2),
      child: Text(
        title,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accentOrange, letterSpacing: 0.6),
      ),
    );
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final repo = ref.read(orderRepositoryProvider);
    final authUser = ref.read(authProvider).user;

    final orderId = _isEditing ? widget.orderId! : 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final qty = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    final netWt = double.tryParse(_netWeightUkaiController.text.trim());
    final expText = _expensesController.text.trim();

    if (!_isEditing) {
      final existingOrders = await repo.getOrders();
      final duplicate = existingOrders.any((o) =>
          o.vehicleNumber.toLowerCase() == _vehicleController.text.trim().toLowerCase() &&
          o.date.year == _selectedDate.year &&
          o.date.month == _selectedDate.month &&
          o.date.day == _selectedDate.day &&
          o.toLocation.toLowerCase() == _toController.text.trim().toLowerCase());

      if (duplicate && context.mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
                SizedBox(width: 6),
                Text('Duplicate Order', style: TextStyle(fontSize: 15)),
              ],
            ),
            content: Text(
              'A trip order for vehicle ${_vehicleController.text} to ${_toController.text} on ${DateFormatter.formatDate(_selectedDate)} already exists.\n\nSave anyway?',
              style: const TextStyle(fontSize: 13),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
                child: const Text('Save'),
              ),
            ],
          ),
        );

        if (proceed != true) {
          setState(() => _isLoading = false);
          return;
        }
      }
    }

    final newOrder = OrderModel(
      id: orderId,
      date: _selectedDate,
      vehicleNumber: _vehicleController.text.trim(),
      fromLocation: _fromController.text.trim(),
      toLocation: _toController.text.trim(),
      material: _selectedMaterial,
      quantity: qty,
      netWeightUkai: netWt,
      company: _selectedCompany,
      expenses: expText.isEmpty ? null : expText,
      attachmentPath: _attachmentPath,
      attachmentName: _attachmentName,
      attachmentSize: _attachmentSize,
      status: _selectedStatus,
      createdBy: authUser?.name ?? 'Admin',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_isEditing) {
      await repo.updateOrder(newOrder);
    } else {
      await repo.addOrder(newOrder);
    }

    setState(() => _isLoading = false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Order updated successfully!' : 'Order saved & broadcast to all admin devices!'),
          backgroundColor: AppColors.statusDelivered,
        ),
      );
      context.pop();
    }
  }
}
