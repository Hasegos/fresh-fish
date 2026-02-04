// screens/decoration_manager_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_data_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../models/user_data_model.dart';

/// 장식 관리 화면
class DecorationManagerScreen extends StatefulWidget {
  const DecorationManagerScreen({super.key});

  @override
  State<DecorationManagerScreen> createState() => _DecorationManagerScreenState();
}

class _DecorationManagerScreenState extends State<DecorationManagerScreen> {
  int _selectedTabIndex = 1; // 기본값: 정식 관리
  PlacedDecoration? _selectedShelfDecoration; // 장식장에서 선택된 장식

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: Consumer<UserDataProvider>(
                builder: (context, provider, child) {
                  if (provider.userData == null) {
                    return const Center(child: Text('데이터 없음'));
                  }

                  final decorations = provider.userData!.decorations;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildStatsSection(decorations.length),
                        _buildInfoBox(),
                        _buildAquariumSection(
                          context,
                          decorations,
                          provider,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 4,
        onTap: (index) {},
      ),
    );
  }

  /// 상단 헤더
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.read<UserDataProvider>().backToMain(),
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              const Text(
                '🎨 정식 관리',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Consumer<UserDataProvider>(
            builder: (context, provider, child) {
              final gold = provider.userData?.gold ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5B4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '⭐ $gold',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 탭 바
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildTab('정식 보유', 0),
          const SizedBox(width: 12),
          _buildTab('정식 관리', 1),
          const SizedBox(width: 12),
          _buildTab('스킨테마', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPastel : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryPastel : AppColors.textSecondary,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 통계 섹션
  Widget _buildStatsSection(int decorationCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('🔴 $decorationCount개', '배치 중'),
            _buildStatItem('🔵 1개', '사용중'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 정보 박스
  Widget _buildInfoBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC8E6C9)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '장식을 드래그하여 위치를 변경하고, 길게 누르면 삭제할 수 있습니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF2E7D32),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 수족관 섹션 (메인 수족관 + 장식 관리 수족관 + 팔레트)
  Widget _buildAquariumSection(
    BuildContext context,
    List<PlacedDecoration> decorations,
    UserDataProvider provider,
  ) {
    final shelfLayout = provider.userData?.decorationShelfLayout ?? [];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🐠 메인 수족관',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // 메인 수족관 - 현재 배치된 장식들
          _buildMainAquarium(context, decorations, provider),
          const SizedBox(height: 24),
          
          Text(
            '🎨 장식 관리 수족관',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // 장식 관리 수족관
          _buildDecorationsShelfAquarium(context, shelfLayout, provider),
          const SizedBox(height: 24),
          
          Text(
            '📦 사용 가능한 장식',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // 사용 가능한 장식 목록 (팔레트)
          _buildDecorationPalette(context, provider),
        ],
      ),
    );
  }

  /// 메인 수족관 (읽기 전용)
  Widget _buildMainAquarium(
    BuildContext context,
    List<PlacedDecoration> decorations,
    UserDataProvider provider,
  ) {
    return Center(
      child: Container(
        width: 280,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.7),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Stack(
        children: [
          // 수족관 배경 그래디언트
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0D47A1).withValues(alpha: 0.6),
                  const Color(0xFF1A237E).withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          // 장식 아이템들 (드래그 불가능)
          ...decorations.map((decoration) {
            return Positioned(
              left: decoration.x,
              top: decoration.y,
              child: Text(
                _getDecorationEmoji(decoration.decorationId),
                style: const TextStyle(fontSize: 30),
              ),
            );
          }),
        ],
      ),
    )
    );
  }

  /// 장식 관리 수족관 (드래그, 추가, 제거 가능)
  Widget _buildDecorationsShelfAquarium(
    BuildContext context,
    List<PlacedDecoration> shelfLayout,
    UserDataProvider provider,
  ) {
    return Center(
      child: Container(
        width: 280,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF81C784).withValues(alpha: 0.7),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
        children: [
          // 수족관 배경 그래디언트
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0D47A1).withValues(alpha: 0.6),
                  const Color(0xFF1A237E).withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          // 장식 아이템들 (드래그 가능)
          ...shelfLayout.map((decoration) {
            return _buildDraggableShelfDecoration(
              context,
              decoration,
              provider,
            );
          }),
        ],
      ),
      ),
    );
  }

  /// 드래그 가능한 수족관 장식 (장식장용)
  Widget _buildDraggableShelfDecoration(
    BuildContext context,
    PlacedDecoration decoration,
    UserDataProvider provider,
  ) {
    final containerWidth = 280.0;
    final containerHeight = 200.0;

    return Positioned(
      left: decoration.x,
      top: decoration.y,
      child: GestureDetector(
        onPanUpdate: (details) {
          final newX = (decoration.x + details.delta.dx).clamp(0.0, containerWidth - 30.0);
          final newY = (decoration.y + details.delta.dy).clamp(0.0, containerHeight - 30.0);
          provider.updateShelfDecorationPosition(decoration.decorationId, newX, newY);
        },
        onTap: () {
          setState(() {
            _selectedShelfDecoration = 
                _selectedShelfDecoration?.decorationId == decoration.decorationId 
                    ? null 
                    : decoration;
          });
        },
        onLongPress: () {
          _showShelfDecorationMenu(context, decoration, provider);
        },
        child: Container(
          decoration: BoxDecoration(
            border: _selectedShelfDecoration?.decorationId == decoration.decorationId
                ? Border.all(color: Colors.blue.shade300, width: 2)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getDecorationEmoji(decoration.decorationId),
            style: const TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }

  /// 장식 팔레트 (사용 가능한 장식들)
  Widget _buildDecorationPalette(
    BuildContext context,
    UserDataProvider provider,
  ) {
    final ownedDecorations = provider.userData?.ownedDecorations ?? [];
    final shelfLayout = provider.userData?.decorationShelfLayout ?? [];
    final shelfDecorationIds = shelfLayout.map((d) => d.decorationId).toSet();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final decorationId in ownedDecorations)
              _buildPaletteItem(
                context,
                decorationId,
                provider,
                isInShelf: shelfDecorationIds.contains(decorationId),
              ),
          ],
        ),
      ),
    );
  }

  /// 팔레트 아이템
  Widget _buildPaletteItem(
    BuildContext context,
    String decorationId,
    UserDataProvider provider,
    {required bool isInShelf}
  ) {
    return GestureDetector(
      onTap: () {
        if (!isInShelf) {
          // 수족관에 추가
          provider.addToDecorationShelf(decorationId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getDecorationName(decorationId)} 추가됨'),
              backgroundColor: Colors.green,
              duration: const Duration(milliseconds: 1500),
            ),
          );
        }
      },
      onDoubleTap: () {
        if (isInShelf) {
          // 더블 클릭으로 제거
          provider.removeFromDecorationShelf(decorationId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getDecorationName(decorationId)} 제거됨'),
              backgroundColor: Colors.orange,
              duration: const Duration(milliseconds: 1500),
            ),
          );
        }
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isInShelf ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isInShelf ? Colors.blue : const Color(0xFFDDDDDD),
            width: isInShelf ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              _getDecorationEmoji(decorationId),
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 4),
            Text(
              _getDecorationName(decorationId),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (isInShelf)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '배치중',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '사용가능',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 장식 메뉴 (장식장)
  void _showShelfDecorationMenu(
    BuildContext context,
    PlacedDecoration decoration,
    UserDataProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getDecorationName(decoration.decorationId),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('수족관에서 제거', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  provider.removeFromDecorationShelf(decoration.decorationId);
                  setState(() {
                    _selectedShelfDecoration = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${_getDecorationName(decoration.decorationId)} 제거됨'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 장식 이모지 가져오기
  String _getDecorationEmoji(String decorationId) {
    const decorations = {
      'deco_01': '🪨',
      'deco_02': '🏴‍☠️',
      'deco_03': '🌿',
    };
    return decorations[decorationId] ?? '❓';
  }

  /// 장식 이름 가져오기
  String _getDecorationName(String decorationId) {
    const decorations = {
      'deco_01': '신은 돌',
      'deco_02': '황금 보물상자',
      'deco_03': '해초 숲',
    };
    return decorations[decorationId] ?? '알 수 없는 장식';
  }
}
