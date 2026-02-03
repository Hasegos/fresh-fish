import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// 공통 다이얼로그 위젯
class CommonDialogs {
  /// 확인 다이얼로그
  static Future<bool> showConfirmDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = '확인',
        String cancelText = '취소',
        bool isDangerous = false,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      useRootNavigator: true, // ✅ 안정화
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(
              isDangerous ? Icons.warning : Icons.info,
              color: isDangerous ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: AppTextStyles.h3),
            ),
          ],
        ),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? AppColors.error : AppColors.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// 알림 다이얼로그
  static Future<void> showAlertDialog(
      BuildContext context, {
        required String title,
        required String message,
        String buttonText = '확인',
      }) async {
    await showDialog<void>(
      context: context,
      useRootNavigator: true, // ✅ 안정화
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: AppTextStyles.h3),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// 입력 다이얼로그 (방법 A)
  static Future<String?> showInputDialog(
      BuildContext context, {
        required String title,
        String? hint,
        String? initialValue,
        String confirmText = '확인',
        String cancelText = '취소',
      }) async {
    final controller = TextEditingController(text: initialValue ?? '');

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true, // ✅ 안정화
      builder: (dialogContext) {
        void submit() {
          final text = controller.text.trim();
          Navigator.of(dialogContext, rootNavigator: true)
              .pop(text.isEmpty ? null : text);
        }

        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(title, style: AppTextStyles.h3),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: hint),
            onSubmitted: (_) => submit(),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext, rootNavigator: true).pop(null),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: submit,
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  /// 로딩 다이얼로그 표시
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true, // ✅ 핵심
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message, style: AppTextStyles.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 로딩 다이얼로그 닫기
  static void hideLoadingDialog(BuildContext context) {
    // ✅ rootNavigator 기준으로 안전하게 닫기
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) {
      nav.pop();
    }
  }

  /// 선택 다이얼로그
  static Future<T?> showChoiceDialog<T>(
      BuildContext context, {
        required String title,
        required List<ChoiceItem<T>> choices,
      }) async {
    return await showDialog<T>(
      context: context,
      useRootNavigator: true, // ✅ 안정화
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: choices.map((choice) {
            return ListTile(
              leading: choice.icon != null
                  ? Icon(choice.icon, color: AppColors.primary)
                  : null,
              title: Text(choice.label, style: AppTextStyles.bodyLarge),
              subtitle: choice.subtitle != null
                  ? Text(choice.subtitle!, style: AppTextStyles.caption)
                  : null,
              onTap: () => Navigator.of(dialogContext, rootNavigator: true)
                  .pop(choice.value),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 바텀 시트 다이얼로그
  static Future<T?> showBottomSheet<T>(
      BuildContext context, {
        required Widget child,
      }) async {
    return await showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,     // ✅ 핵심
      isScrollControlled: true,   // ✅ 키보드/리빌드 안정화
      useSafeArea: true,          // ✅
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => child,
    );
  }
}

/// 선택 아이템
class ChoiceItem<T> {
  final String label;
  final String? subtitle;
  final IconData? icon;
  final T value;

  ChoiceItem({
    required this.label,
    this.subtitle,
    this.icon,
    required this.value,
  });
}
