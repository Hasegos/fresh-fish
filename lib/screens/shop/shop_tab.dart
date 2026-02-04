import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/decorations.dart';
import '../../models/decoration_model.dart' as deco_model;
import '../../providers/user_data_provider.dart';
import 'purchase_confirm_dialog.dart';
import 'shop_colors.dart';

// ========== 장식 상점 탭 ==========
class ShopTab extends StatelessWidget {
  const ShopTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, provider, child) {
        final owned = provider.userData?.ownedDecorations ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: availableDecorations.length,
            itemBuilder: (context, index) {
              final decoration = availableDecorations[index];
              final isOwned = owned.contains(decoration.id);

              return _DecorationCard(
                decoration: decoration,
                isOwned: isOwned,
                onBuy: () => _buyDecoration(context, provider, decoration),
              );
            },
          ),
        );
      },
    );
  }

  void _buyDecoration(BuildContext context, UserDataProvider provider,
      deco_model.Decoration decoration) {
    final userData = provider.userData;
    if (userData == null) return;

    // 이미 소유했는지 확인
    if (userData.ownedDecorations.contains(decoration.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 ${decoration.name}을(를) 소유했습니다.')),
      );
      return;
    }

    // 골드 부족 확인
    if (userData.gold < decoration.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${decoration.name} 구매에 필요한 골드가 부족합니다.')),
      );
      return;
    }

    // 구매 확인 대화상자
    showDialog(
      context: context,
      builder: (context) => PurchaseConfirmDialog(
        itemName: decoration.name,
        icon: decoration.icon,
        description: decoration.description,
        cost: decoration.cost,
        onConfirm: () => provider.purchaseDecoration(
          decoration.id,
          decoration.cost,
        ),
      ),
    ).then((success) {
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${decoration.name}을(를) 구매했습니다!')),
        );
      } else if (success == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${decoration.name} 구매에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}

class _DecorationCard extends StatelessWidget {
  final deco_model.Decoration decoration;
  final bool isOwned;
  final VoidCallback onBuy;

  const _DecorationCard({
    required this.decoration,
    required this.isOwned,
    required this.onBuy,
  });

  Color _getRarityColor() {
    switch (decoration.rarity) {
      case deco_model.Rarity.common:
        return ShopColors.rarityCommon;
      case deco_model.Rarity.rare:
        return ShopColors.rarityRare;
      case deco_model.Rarity.epic:
        return ShopColors.rarityEpic;
      case deco_model.Rarity.legendary:
        return ShopColors.rarityLegendary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isOwned ? null : onBuy,
      child: Container(
        decoration: BoxDecoration(
          color: ShopColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRarityColor(),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getRarityColor().withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          decoration.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ShopColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRarityColor(),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getRarityLabel(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    decoration.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: ShopColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      decoration.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isOwned ? null : onBuy,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOwned
                            ? ShopColors.disabledButton
                            : ShopColors.primaryButton,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isOwned ? '보유 중' : '💰 ${decoration.cost}',
                        style: TextStyle(
                          color: isOwned
                              ? ShopColors.textDisabled
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRarityLabel() {
    switch (decoration.rarity) {
      case deco_model.Rarity.common:
        return '일반';
      case deco_model.Rarity.rare:
        return '레어';
      case deco_model.Rarity.epic:
        return '에픽';
      case deco_model.Rarity.legendary:
        return '레전더리';
    }
  }
}
