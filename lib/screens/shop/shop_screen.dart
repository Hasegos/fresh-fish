import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/decorations.dart';
import '../../data/skins.dart';
import '../../models/decoration_model.dart';
import '../../models/skin_model.dart';
import '../../providers/user_data_provider.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B7280)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '🏪 장식 관리',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<UserDataProvider>(
              builder: (context, provider, child) {
                final gold = provider.userData?.gold ?? 0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '💰',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$gold G',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B5000),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF3B82F6),
          tabs: const [
            Tab(text: '장식 상점'),
            Tab(text: '장식 관리'),
            Tab(text: '스킨 테마'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ShopTab(),
          _ManageTab(),
          _SkinTab(),
        ],
      ),
    );
  }
}

// ========== 장식 상점 탭 ==========
class _ShopTab extends StatelessWidget {
  const _ShopTab();

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
      Decoration decoration) {
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
      builder: (context) => AlertDialog(
        title: Text(decoration.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(decoration.icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(decoration.description),
            const SizedBox(height: 12),
            Text(
              '${decoration.cost} G에 구매하시겠습니까?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.purchaseDecoration(decoration.id, decoration.cost);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${decoration.name}을(를) 구매했습니다!')),
              );
            },
            child: const Text('구매'),
          ),
        ],
      ),
    );
  }
}

class _DecorationCard extends StatelessWidget {
  final Decoration decoration;
  final bool isOwned;
  final VoidCallback onBuy;

  const _DecorationCard({
    required this.decoration,
    required this.isOwned,
    required this.onBuy,
  });

  Color _getRarityColor() {
    switch (decoration.rarity) {
      case Rarity.common:
        return const Color(0xFF3B82F6);
      case Rarity.rare:
        return const Color(0xFF8B5CF6);
      case Rarity.epic:
        return const Color(0xFFEC4899);
      case Rarity.legendary:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isOwned ? null : onBuy,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRarityColor(),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getRarityColor().withOpacity(0.2),
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
                            color: Color(0xFF1F2937),
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
                      color: Color(0xFF6B7280),
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
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isOwned ? '보유 중' : '💰 ${decoration.cost}',
                        style: TextStyle(
                          color: isOwned
                              ? const Color(0xFF9CA3AF)
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
      case Rarity.common:
        return '일반';
      case Rarity.rare:
        return '레어';
      case Rarity.epic:
        return '에픽';
      case Rarity.legendary:
        return '레전더리';
    }
  }
}

// ========== 장식 관리 탭 ==========
class _ManageTab extends StatelessWidget {
  const _ManageTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, provider, child) {
        final owned = provider.userData?.ownedDecorations ?? [];
        final ownedDecorations = availableDecorations
            .where((d) => owned.contains(d.id))
            .toList();

        if (ownedDecorations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🪨',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                const Text('아직 소유한 장식이 없습니다'),
                const SizedBox(height: 8),
                const Text('장식 상점에서 아이템을 구매해보세요!',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '보유 중: ${ownedDecorations.length}개',
                        style: const TextStyle(
                          color: Color(0xFF1E40AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: ownedDecorations.length,
                itemBuilder: (context, index) {
                  final decoration = ownedDecorations[index];
                  return _OwnedDecorationCard(decoration: decoration);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OwnedDecorationCard extends StatelessWidget {
  final Decoration decoration;

  const _OwnedDecorationCard({required this.decoration});

  Color _getRarityColor() {
    switch (decoration.rarity) {
      case Rarity.common:
        return const Color(0xFF3B82F6);
      case Rarity.rare:
        return const Color(0xFF8B5CF6);
      case Rarity.epic:
        return const Color(0xFFEC4899);
      case Rarity.legendary:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRarityColor(),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getRarityColor().withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
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
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '보유중',
                    style: TextStyle(
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
                color: Color(0xFF6B7280),
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '배치하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== 스킨 테마 탭 ==========
class _SkinTab extends StatelessWidget {
  const _SkinTab();

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
      builder: (context) => AlertDialog(
        title: Text(skin.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(skin.icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(skin.description),
            const SizedBox(height: 12),
            Text(
              '${skin.cost} G에 구매하시겠습니까?',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.purchaseSkin(skin.id, skin.cost);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${skin.name}을(를) 구매했습니다!')),
              );
            },
            child: const Text('구매'),
          ),
        ],
      ),
    );
  }

  void _selectSkin(BuildContext context, UserDataProvider provider, Skin skin) {
    provider.selectSkin(skin.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${skin.name}으로 변경했습니다!')),
    );
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
        return const Color(0xFF3B82F6);
      case SkinRarity.uncommon:
        return const Color(0xFF10B981);
      case SkinRarity.rare:
        return const Color(0xFF8B5CF6);
      case SkinRarity.epic:
        return const Color(0xFFEC4899);
      case SkinRarity.legendary:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isOwned && !isActive ? onSelect : (isOwned ? null : onBuy),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRarityColor(),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getRarityColor().withOpacity(0.2),
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
                            color: Color(0xFF1F2937),
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
                      color: Color(0xFF6B7280),
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
                            ? const Color(0xFF10B981)
                            : (isOwned
                                ? const Color(0xFFFCD34D)
                                : const Color(0xFF3B82F6)),
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
                                  ? const Color(0xFF8B5000)
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