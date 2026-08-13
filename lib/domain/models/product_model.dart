import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final int totalOrders;
  final double totalQuantity;
  final IconData icon;
  final List<Color> gradient;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.totalOrders,
    required this.totalQuantity,
    required this.icon,
    required this.gradient,
  });
}
