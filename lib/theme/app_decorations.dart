import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 앱 전역 BoxDecoration 스타일
class AppDecorations {
  /// 기본 카드 데코레이션
  static BoxDecoration card({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// 그라데이션 카드 데코레이션
  static BoxDecoration gradientCard({Gradient? gradient}) {
    return BoxDecoration(
      gradient: gradient ?? AppColors.cardGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// 수족관 배경 데코레이션
  static BoxDecoration aquariumBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A3A52),
          Color(0xFF0D1B2A),
        ],
      ),
    );
  }

  /// 버튼 데코레이션
  static BoxDecoration button({
    Color? color,
    bool isOutlined = false,
  }) {
    return BoxDecoration(
      color: isOutlined ? Colors.transparent : (color ?? AppColors.primary),
      border: isOutlined
          ? Border.all(color: color ?? AppColors.primary, width: 2)
          : null,
      borderRadius: BorderRadius.circular(12),
      boxShadow: isOutlined
          ? null
          : [
              BoxShadow(
                color: (color ?? AppColors.primary).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }

  /// 입력 필드 데코레이션
  static InputDecoration input({
    String? hintText,
    String? labelText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.textDisabled),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.textDisabled),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  /// 배지 데코레이션
  static BoxDecoration badge({Color? color}) {
    return BoxDecoration(
      color: (color ?? AppColors.primary).withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: (color ?? AppColors.primary).withOpacity(0.3),
      ),
    );
  }

  /// 원형 아바타 데코레이션
  static BoxDecoration avatar({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.primary.withOpacity(0.2),
      shape: BoxShape.circle,
      border: Border.all(
        color: color ?? AppColors.primary,
        width: 2,
      ),
    );
  }
}
