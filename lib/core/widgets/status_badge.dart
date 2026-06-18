// FILE: lib/core/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Badge trạng thái tái sử dụng — hiển thị dot + label màu sắc theo trạng thái
class StatusBadge extends StatelessWidget {
  final String label;
  final Color  color;

  const StatusBadge({super.key, required this.label, required this.color});

  // Named constructors cho các trạng thái phổ biến
  // (không dùng factory + const để tránh key conflict)
  static StatusBadge active()   => const StatusBadge(label: 'Hoạt động',   color: AppColors.statusActive);
  static StatusBadge draft()    => const StatusBadge(label: 'Nháp',         color: AppColors.statusDraft);
  static StatusBadge inactive() => const StatusBadge(label: 'Dừng',         color: AppColors.textSecondary);
  static StatusBadge offline()  => const StatusBadge(label: 'Offline',      color: AppColors.amber);
  static StatusBadge synced()   => const StatusBadge(label: 'Đã đồng bộ',  color: AppColors.statusActive);
  static StatusBadge pending()  => const StatusBadge(label: 'Chờ đồng bộ', color: AppColors.amber);
  static StatusBadge locked()   => const StatusBadge(label: 'Đã khóa',     color: AppColors.red);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
