import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case AppConstants.statusPending:
        bg = AppColors.statusPending.withOpacity(0.18);
        fg = AppColors.statusPending;
        icon = Icons.access_time_rounded;
        break;
      case AppConstants.statusInTransit:
        bg = AppColors.statusInTransit.withOpacity(0.18);
        fg = AppColors.statusInTransit;
        icon = Icons.local_shipping_rounded;
        break;
      case AppConstants.statusDelivered:
        bg = AppColors.statusDelivered.withOpacity(0.18);
        fg = AppColors.statusDelivered;
        icon = Icons.assignment_turned_in_rounded;
        break;
      case AppConstants.statusCompleted:
      default:
        bg = AppColors.statusCompleted.withOpacity(0.18);
        fg = AppColors.statusCompleted;
        icon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: fg),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
