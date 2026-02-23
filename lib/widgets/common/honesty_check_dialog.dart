import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// 정직성 확인 다이얼로그
class HonestyCheckDialog extends StatefulWidget {
  final String questTitle;
  final Function(bool honest, String? emotion)? onConfirm;
  final VoidCallback? onCancel;

  const HonestyCheckDialog({
    Key? key,
    required this.questTitle,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  State<HonestyCheckDialog> createState() => _HonestyCheckDialogState();

  /// 다이얼로그 표시
  static Future<void> show(
    BuildContext context, {
    required String questTitle,
    Function(bool honest, String? emotion)? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => HonestyCheckDialog(
        questTitle: questTitle,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}

class _HonestyCheckDialogState extends State<HonestyCheckDialog> {
  String? _selectedEmotion;
  bool _showEmotions = false;

  final List<Map<String, dynamic>> _emotions = [
    {
      'id': 'great',
      'icon': Icons.sentiment_very_satisfied,
      'label': '정말 뿌듯해요!',
      'color': Colors.green,
    },
    {
      'id': 'good',
      'icon': Icons.sentiment_neutral,
      'label': '괜찮아요',
      'color': Colors.orange,
    },
    {
      'id': 'okay',
      'icon': Icons.sentiment_dissatisfied,
      'label': '조금 아쉬워요',
      'color': Colors.deepOrange,
    },
  ];

  void _handleYes() {
    setState(() {
      _showEmotions = true;
    });
  }

  void _handleNo() {
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  void _handleEmotionSelect(String emotionId) {
    setState(() {
      _selectedEmotion = emotionId;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onConfirm?.call(true, emotionId);
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: _showEmotions ? _buildEmotionSelection() : _buildHonestyCheck(),
      ),
    );
  }

  Widget _buildHonestyCheck() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 아이콘
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),

        // 제목
        Text(
          '정직하게 답변해주세요',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),

        // 퀘스트 제목
        Text(
          '"${widget.questTitle}"',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        Text(
          '정말로 정직하게 수행하셨나요?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // 액션 버튼들
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleYes,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '네, 정직하게 완료했습니다 ✓',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleNo,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.grey.shade700),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '아니요, 다시 생각해볼게요',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
          child: Text(
            '취소',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '기분이 어떠세요?',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          '오늘의 감정을 기록해보세요',
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 24),
        ..._emotions.map((emotion) {
          final isSelected = _selectedEmotion == emotion['id'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _handleEmotionSelect(emotion['id'] as String),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.3)
                      : const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      emotion['icon'] as IconData,
                      color: emotion['color'] as Color,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      emotion['label'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
