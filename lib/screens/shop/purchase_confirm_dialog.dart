import 'package:flutter/material.dart';
import 'shop_colors.dart';

/// 상점 아이템 구매 확인 다이얼로그
/// onConfirm이 true를 반환하면 성공, false를 반환하면 실패
class PurchaseConfirmDialog extends StatefulWidget {
  final String itemName;
  final String icon;
  final String description;
  final int cost;
  final Future<bool> Function()? onConfirm;

  const PurchaseConfirmDialog({
    super.key,
    required this.itemName,
    required this.icon,
    required this.description,
    required this.cost,
    this.onConfirm,
  });

  @override
  State<PurchaseConfirmDialog> createState() => _PurchaseConfirmDialogState();
}

class _PurchaseConfirmDialogState extends State<PurchaseConfirmDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.itemName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(widget.description),
          const SizedBox(height: 12),
          Text(
            '${widget.cost} G에 구매하시겠습니까?',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  if (widget.onConfirm == null) {
                    Navigator.pop(context);
                    return;
                  }

                  setState(() => _isLoading = true);
                  try {
                    final success = await widget.onConfirm!();
                    if (mounted) {
                      Navigator.pop(context, success);
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context, false);
                    }
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('구매'),
        ),
      ],
    );
  }
}
