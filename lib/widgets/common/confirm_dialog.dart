import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

/// 확인 다이얼로그
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final DialogType type;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = '확인',
    this.cancelText = '취소',
    required this.onConfirm,
    required this.onCancel,
    this.type = DialogType.warning,
  }) : super(key: key);

  /// 다이얼로그 표시
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    DialogType type = DialogType.warning,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel ?? () => Navigator.of(context).pop(),
        type: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getTypeColors(type);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors['bg'] as Color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors['border'] as Color,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: colors['icon'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),

            // 제목
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 8),

            // 메시지
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors['button'] as Color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Color> _getTypeColors(DialogType type) {
    switch (type) {
      case DialogType.warning:
        return {
          'bg': Colors.yellow.shade50,
          'border': Colors.yellow.shade200,
          'icon': Colors.yellow.shade700,
          'button': Colors.yellow.shade600,
        };
      case DialogType.danger:
        return {
          'bg': Colors.red.shade50,
          'border': Colors.red.shade200,
          'icon': Colors.red.shade700,
          'button': Colors.red.shade600,
        };
      case DialogType.info:
        return {
          'bg': Colors.blue.shade50,
          'border': Colors.blue.shade200,
          'icon': Colors.blue.shade700,
          'button': Colors.blue.shade600,
        };
    }
  }
}

enum DialogType {
  warning,
  danger,
  info,
}
