import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 앱 전역 BoxDecoration 스타일 (부드러운 파스텔 톤 설계)
/// 
/// 디자인 가이드라인:
/// - Border Radius: 20-24dp (둥글고 부드러운 느낌)
/// - 그림자: 미묘함 (elevation 0-2)
/// - 경계선: 선택적으로 사용 (너무 강하지 않게)
class AppDecorations {
  // ============ 카드 데코레이션 ============
  
  /// 기본 카드 (최소 그림자)
  static BoxDecoration card({Color? color, double elevation = 1}) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
      border: Border.all(
        color: const Color(0xFFEEEEEE),
        width: 0.5,
      ),
    );
  }

  /// 높은 엘리베이션 카드
  static BoxDecoration cardElevated({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ],
      border: Border.all(
        color: const Color(0xFFEEEEEE),
        width: 0.5,
      ),
    );
  }

  /// 그라데이션 카드 (파스텔 톤)
  static BoxDecoration gradientCard({
    Gradient? gradient,
    double radius = 20,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppColors.cardGradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: Colors.white.withOpacity(0.5),
        width: 0.5,
      ),
    );
  }

  // ============ 배경 데코레이션 ============
  
  /// 페이지 배경
  static BoxDecoration pageBackground() {
    return const BoxDecoration(
      color: AppColors.background,
      gradient: AppColors.backgroundGradient,
    );
  }

  /// 수족관 배경 (파스텔 톤)
  static BoxDecoration aquariumBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE3F2FD), // 매우 밝은 파란색
          Color(0xFFF3E5F5), // 매우 밝은 보라색
          Color(0xFFF0F4C3), // 매우 밝은 노란색
        ],
      ),
    );
  }

  // ============ 버튼 데코레이션 ============
  
  /// 기본 버튼
  static BoxDecoration button({
    Color? color,
    double radius = 24,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.primary,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: (color ?? AppColors.primary).withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// 아웃라인 버튼
  static BoxDecoration outlineButton({
    Color? color,
    double radius = 24,
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      color: Colors.transparent,
      border: Border.all(
        color: color ?? AppColors.primary,
        width: borderWidth,
      ),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// 선택된 버튼 (배경 색상 있음)
  static BoxDecoration selectedButton({Color? color, double radius = 24}) {
    return BoxDecoration(
      color: (color ?? AppColors.primary).withOpacity(0.1),
      border: Border.all(
        color: color ?? AppColors.primary,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  // ============ 입력 필드 데코레이션 ============
  
  /// 입력 필드 데코레이션
  static InputDecoration input({
    String? hintText,
    String? labelText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    double radius = 20,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // ============ 배지 및 라벨 데코레이션 ============
  
  /// 일반 배지
  static BoxDecoration badge({
    Color? color,
    double radius = 12,
    bool filled = true,
  }) {
    final bgColor = color ?? AppColors.primary;
    return BoxDecoration(
      color: filled ? bgColor.withOpacity(0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: bgColor.withOpacity(0.4),
        width: 0.5,
      ),
    );
  }

  /// 상태 배지
  static BoxDecoration statusBadge({
    required String status,
    double radius = 12,
  }) {
    Color color;
    switch (status) {
      case 'complete':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'missed':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textTertiary;
    }
    return badge(color: color, radius: radius);
  }

  // ============ 아바타 데코레이션 ============
  
  /// 원형 아바타
  static BoxDecoration avatar({
    Color? color,
    double size = 48,
  }) {
    return BoxDecoration(
      color: (color ?? AppColors.primary).withOpacity(0.2),
      shape: BoxShape.circle,
      border: Border.all(
        color: color ?? AppColors.primary,
        width: 2,
      ),
    );
  }

  /// 둥근 사각형 아바타
  static BoxDecoration avatarRounded({
    Color? color,
    double radius = 16,
  }) {
    return BoxDecoration(
      color: (color ?? AppColors.primary).withOpacity(0.15),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: (color ?? AppColors.primary).withOpacity(0.5),
        width: 1,
      ),
    );
  }

  // ============ 진행 표시기 데코레이션 ============
  
  /// 선형 진행률 바 배경
  static BoxDecoration progressBarBackground({double radius = 12}) {
    return BoxDecoration(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// 진행률 바 채움
  static BoxDecoration progressBarFill({
    Color? color,
    double radius = 12,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.primary,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: (color ?? AppColors.primary).withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
      gradient: AppColors.progressGradient,
    );
  }

  // ============ 기타 데코레이션 ============
  
  /// 디바이더 스타일
  static BoxDecoration divider({Color? color, double thickness = 1}) {
    return BoxDecoration(
      color: color ?? const Color(0xFFEEEEEE),
      borderRadius: BorderRadius.circular(thickness / 2),
    );
  }

  /// 그룹 섹션 (여러 카드 묶음)
  static BoxDecoration groupSection({Color? backgroundColor}) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFEEEEEE),
        width: 0.5,
      ),
    );
  }

  /// 특별 강조 카드 (라벤더/핑크)
  static BoxDecoration featureCard({Color? accentColor}) {
    final color = accentColor ?? AppColors.accent;
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: color.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
