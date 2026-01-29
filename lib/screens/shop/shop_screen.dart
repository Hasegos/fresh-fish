// screens/shop/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/decorations.dart';
import '../../data/skins.dart';
import '../../models/skin_model.dart';
import '../../models/user_data_model.dart';
import '../../providers/user_data_provider.dart';
import '../../models/decoration_model.dart' as decoration_models;
import '../../models/decoration_model.dart' show Rarity;

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),

            // 탭 버튼
            _buildTabButtons(),

            // 컨텐츠
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {});
                },
                children: [
                  _DecorationShopTab(),
                  _DecorationManagerTab(),
                  _SkinShopTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1976D2), size: 24),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '🏪 장식 관리',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const Spacer(),
          Consumer<UserDataProvider>(
            builder: (context, provider, child) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '💰 ${provider.userData?.gold ?? 0}G',
                style: const TextStyle(
                  color: Color(0xFFFF9800),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    final tabs = ['장식 상점', '장식 관리', '스킨 테마'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF42A5F5).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF42A5F5).withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _pageController.hasClients
                ? (_pageController.page?.round() ?? 0) == index
                : false;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF42A5F5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF42A5F5),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// =============== 탭 1: 장식 상점 ===============
class _DecorationShopTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Consumer<UserDataProvider>(
          builder: (context, provider, _) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: availableDecorations.length,
              itemBuilder: (context, index) {
                final decoration = availableDecorations[index];
                final isOwned =
                    provider.userData?.ownedDecorations.contains(decoration.id) ??
                        false;

                return _buildDecorationCard(
                  context,
                  decoration,
                  isOwned,
                  provider,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDecorationCard(
    BuildContext context,
    decoration_models.Decoration decoration,
    bool isOwned,
    UserDataProvider provider,
  ) {
    final rarityColors = {
      Rarity.common: const Color(0xFF90A4AE),
      Rarity.rare: const Color(0xFF4FC3F7),
      Rarity.epic: const Color(0xFFBA68C8),
      Rarity.legendary: const Color(0xFFFFD700),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOwned
              ? Colors.green.withValues(alpha: 0.6)
              : rarityColors[decoration.rarity]!.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          decoration.name,
                          style: const TextStyle(
                            color: Color(0xFF0D47A1),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: rarityColors[decoration.rarity],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _rarityLabel(decoration.rarity),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      decoration.description,
                      style: const TextStyle(
                        color: Color(0xFF616161),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      decoration.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isOwned
                            ? null
                            : () => _purchaseDecoration(
                              context,
                              provider,
                              decoration,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOwned
                              ? Colors.green
                              : const Color(0xFF42A5F5),
                          disabledBackgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isOwned
                              ? '보유중'
                              : '💰 ${decoration.cost}G',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _purchaseDecoration(
    BuildContext context,
    UserDataProvider provider,
    decoration_models.Decoration decoration,
  ) async {
    // 구매 시도
    final success = await provider.purchaseDecoration(decoration.id, decoration.cost);
    
    if (success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${decoration.name}을(를) 구매했습니다! (${decoration.cost}G 사용)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('골드가 부족합니다.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _rarityLabel(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return '일반';
      case Rarity.rare:
        return '레어';
      case Rarity.epic:
        return '에픽';
      case Rarity.legendary:
        return '전설';
    }
  }
}

// =============== 탭 2: 장식 관리 ===============
class _DecorationManagerTab extends StatefulWidget {
  @override
  State<_DecorationManagerTab> createState() => _DecorationManagerTabState();
}

class _DecorationManagerTabState extends State<_DecorationManagerTab> {
  final Map<String, Offset> _decorationOffsets = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, provider, _) {
        final ownedIds = provider.userData?.ownedDecorations ?? [];
        final ownedDecorations = availableDecorations
            .where((d) => ownedIds.contains(d.id))
            .toList();
        final placedDecorations = provider.userData?.decorations ?? [];

        if (ownedDecorations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🎁',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '보유 중인 장식이 없습니다',
                    style: TextStyle(
                      color: Color(0xFF616161),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '상점에서 장식을 구매해보세요!',
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // 통계
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildStatsRow(ownedDecorations.length, placedDecorations.length),
            ),

            // 사용 안내
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7DD3C0).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF7DD3C0).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Color(0xFF0D47A1)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '장식을 클릭하면 배치되고, 드래그로 이동할 수 있습니다',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 수족관 영역 (Home 화면과 동일한 크기 및 스타일)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: Container(
                    width: 280,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF7DD3C0).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // 배치된 장식들
                        ...placedDecorations.map((placed) {
                          final decoration = availableDecorations
                              .where((d) => d.id == placed.decorationId)
                              .firstOrNull;
                          
                          if (decoration == null) return const SizedBox.shrink();
                          
                          final offset = _decorationOffsets[placed.decorationId] ?? 
                              Offset(placed.x * 280, placed.y * 200);

                          return Positioned(
                            left: offset.dx,
                            top: offset.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                // 현재 저장된 offset 값에서 새 위치 계산
                                final currentOffset = _decorationOffsets[placed.decorationId] ?? offset;
                                final newOffset = currentOffset + details.delta;
                                final clampedX = newOffset.dx.clamp(0.0, 280.0 - 24);
                                final clampedY = newOffset.dy.clamp(0.0, 200.0 - 24);
                              
                              // 실시간으로 부드럽게 업데이트
                              setState(() {
                                _decorationOffsets[placed.decorationId] = Offset(clampedX, clampedY);
                              });
                            },
                            onPanEnd: (details) {
                              // 드래그 종료 후 데이터 저장
                              final finalOffset = _decorationOffsets[placed.decorationId]!;
                              provider.updateUserData((data) {
                                final updatedDecorations = data.decorations.map((d) {
                                  if (d.decorationId == placed.decorationId) {
                                    return d.copyWith(
                                      x: finalOffset.dx / 280,
                                      y: finalOffset.dy / 200,
                                    );
                                  }
                                  return d;
                                }).toList();
                                return data.copyWith(decorations: updatedDecorations);
                              });
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.grab,
                              child: Transform.translate(
                                offset: const Offset(-12, -12),
                                child: Text(
                                  decoration.icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 하단 장식 목록
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목과 사용 안내
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎁 보유 장식',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '클릭: 배치 | 더블탭: 제거',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF0D47A1).withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: ownedDecorations.length,
                        itemBuilder: (context, index) {
                          final decoration = ownedDecorations[index];
                          final isPlaced = placedDecorations
                              .any((p) => p.decorationId == decoration.id);

                          return GestureDetector(
                            onTap: () {
                              if (!isPlaced) {
                                // 클릭으로 배치
                                _placeDecoration(context, provider, decoration);
                              }
                            },
                            onDoubleTap: () {
                              if (isPlaced) {
                                // 더블 탭으로 삭제
                                _removeDecoration(context, provider, decoration.id);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isPlaced
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFF42A5F5).withValues(alpha: 0.4),
                                  width: isPlaced ? 3 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isPlaced
                                            ? const Color(0xFF4CAF50)
                                            : const Color(0xFF42A5F5))
                                        .withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    decoration.icon,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    decoration.name,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D47A1),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  if (isPlaced)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        '✓ 배치됨',
                                        style: TextStyle(
                                          color: Color(0xFF4CAF50),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _placeDecoration(
    BuildContext context,
    UserDataProvider provider,
    decoration_models.Decoration decoration,
  ) {
    final placedDecoration = PlacedDecoration(
      decorationId: decoration.id,
      x: 0.5,
      y: 0.5,
    );

    _decorationOffsets[decoration.id] = const Offset(112, 80);

    provider.updateUserData((data) {
      final updatedDecorations = [...data.decorations, placedDecoration];
      return data.copyWith(decorations: updatedDecorations);
    }).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${decoration.name}이(가) 배치되었습니다!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _removeDecoration(
    BuildContext context,
    UserDataProvider provider,
    String decorationId,
  ) {
    _decorationOffsets.remove(decorationId);
    
    provider.updateUserData((data) {
      final updatedDecorations =
          data.decorations.where((d) => d.decorationId != decorationId).toList();
      return data.copyWith(decorations: updatedDecorations);
    }).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('장식이 제거되었습니다.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Widget _buildStatsRow(int ownedCount, int placedCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF42A5F5).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF42A5F5).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('🎁', '$ownedCount개', '보유 중'),
          Container(
            width: 2,
            height: 50,
            color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
          ),
          _buildStatItem('🌊', '$placedCount개', '배치됨'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String count, String label) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 6),
        Text(
          count,
          style: const TextStyle(
            color: Color(0xFF0D47A1),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF42A5F5),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// =============== 탭 3: 스킨 테마 ===============
class _SkinShopTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Consumer<UserDataProvider>(
          builder: (context, provider, _) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: availableSkins.length,
              itemBuilder: (context, index) {
                final skin = availableSkins[index];
                final isOwned =
                    provider.userData?.ownedSkins.contains(skin.id) ?? false;
                final isActive = provider.userData?.activeSkinId == skin.id;

                return _buildSkinCard(
                  context,
                  skin,
                  isOwned,
                  isActive,
                  provider,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkinCard(
    BuildContext context,
    Skin skin,
    bool isOwned,
    bool isActive,
    UserDataProvider provider,
  ) {
    final rarityColors = {
      SkinRarity.common: const Color(0xFF90A4AE),
      SkinRarity.uncommon: const Color(0xFF4FC3F7),
      SkinRarity.rare: const Color(0xFF81C784),
      SkinRarity.epic: const Color(0xFFBA68C8),
      SkinRarity.legendary: const Color(0xFFFFD700),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Colors.green.withValues(alpha: 0.6)
              : rarityColors[skin.rarity]!.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
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
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: rarityColors[skin.rarity],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _rarityLabel(skin.rarity),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skin.description,
                      style: const TextStyle(
                        color: Color(0xFF616161),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skin.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isActive
                            ? null
                            : () => _handleSkinAction(
                              context,
                              provider,
                              skin,
                              isOwned,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive
                              ? Colors.green
                              : (isOwned
                                  ? const Color(0xFFFF9800)
                                  : const Color(0xFF42A5F5)),
                          disabledBackgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isActive
                              ? '적용중'
                              : (isOwned
                                  ? '사용'
                                  : (skin.cost == 0
                                      ? '무료'
                                      : '💰 ${skin.cost}G')),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSkinAction(
    BuildContext context,
    UserDataProvider provider,
    Skin skin,
    bool isOwned,
  ) {
    if (isOwned) {
      // 스킨 적용
      provider.setActiveSkin(skin.id);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${skin.name}이(가) 적용되었습니다!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // 스킨 구매
      if (provider.userData!.gold >= skin.cost) {
        provider.purchaseSkin(skin);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${skin.name}을(를) 구매했습니다!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('골드가 부족합니다.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _rarityLabel(SkinRarity rarity) {
    switch (rarity) {
      case SkinRarity.common:
        return '일반';
      case SkinRarity.uncommon:
        return '언커먼';
      case SkinRarity.rare:
        return '레어';
      case SkinRarity.epic:
        return '에픽';
      case SkinRarity.legendary:
        return '전설';
    }
  }
}