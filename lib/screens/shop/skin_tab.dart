import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/skins.dart';
import '../../models/skin_model.dart';
import '../../providers/user_data_provider.dart';
import 'purchase_confirm_dialog.dart';
import 'shop_colors.dart';

// ========== 스킨 테마 탭 ==========
class SkinTab extends StatelessWidget {
  const SkinTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, provider, child) {
        final owned = provider.userData?.ownedSkins ?? [];
        final currentSkinId = provider.userData?.currentSkinId ?? 'skin_default';

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
            itemCount: availableSkins.length,
            itemBuilder: (context, index) {
              final skin = availableSkins[index];
              final isOwned = owned.contains(skin.id);
              final isActive = currentSkinId == skin.id;

              return _SkinCard(
                skin: skin,
                isOwned: isOwned,
                isActive: isActive,
                onBuy: () => _buySkin(context, provider, skin),
                onSelect: isOwned && !isActive
                    ? () => _selectSkin(context, provider, skin)
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  void _buySkin(BuildContext context, UserDataProvider provider, Skin skin) {
    final userData = provider.userData;
    if (userData == null) return;

    if (userData.ownedSkins.contains(skin.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 ${skin.name}을(를) 소유했습니다.')),
      );
      return;
    }

    if (userData.gold < skin.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${skin.name} 구매에 필요한 골드가 부족합니다.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => PurchaseConfirmDialog(
        itemName: skin.name,
        icon: skin.icon,
        description: skin.description,
        cost: skin.cost,
        onConfirm: () => provider.purchaseSkin(skin.id, skin.cost),
      ),
    ).then((success) {
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${skin.name}을(를) 구매했습니다!')),
        );
      } else if (success == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${skin.name} 구매에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _selectSkin(BuildContext context, UserDataProvider provider, Skin skin) async {
    final success = await provider.selectSkin(skin.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${skin.name}으로 변경했습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('스킨 변경에 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _SkinCard extends StatelessWidget {
  final Skin skin;
  final bool isOwned;
  final bool isActive;
  final VoidCallback onBuy;
  final VoidCallback? onSelect;

  const _SkinCard({
    required this.skin,
    required this.isOwned,
    required this.isActive,
    required this.onBuy,
    this.onSelect,
  });

  Color _getRarityColor() {
    switch (skin.rarity) {
      case SkinRarity.common:
        return ShopColors.rarityCommon;
      case SkinRarity.uncommon:
        return ShopColors.rarityUncommon;
      case SkinRarity.rare:
        return ShopColors.rarityRare;
      case SkinRarity.epic:
        return ShopColors.rarityEpic;
      case SkinRarity.legendary:
        return ShopColors.rarityLegendary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isOwned && !isActive ? onSelect : (isOwned ? null : onBuy),
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
                          skin.name,
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
                    skin.description,
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
                      skin.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isActive
                          ? null
                          : (isOwned ? onSelect : onBuy),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? ShopColors.successButton
                            : (isOwned
                                ? ShopColors.warningButton
                                : ShopColors.primaryButton),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isActive
                            ? '선택중'
                            : (isOwned
                                ? '선택'
                                : '💰 ${skin.cost}'),
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : (isOwned
                                  ? ShopColors.warningButtonText
                                  : Colors.white),
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
    switch (skin.rarity) {
      case SkinRarity.common:
        return '일반';
      case SkinRarity.uncommon:
        return '언커먼';
      case SkinRarity.rare:
        return '레어';
      case SkinRarity.epic:
        return '에픽';
      case SkinRarity.legendary:
        return '레전더리';
    }
  }
}
