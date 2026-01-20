import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fish_model.dart';
import '../../providers/app_provider.dart';
import '../../services/storage_service.dart';

/// 알 선택 화면
/// 유저가 처음 앱을 시작할 때 키울 물고기를 고르는 화면입니다.
class EggSelectionScreen extends StatefulWidget {
  final List<String> selectedCategories;

  const EggSelectionScreen({
    Key? key,
    required this.selectedCategories,
  }) : super(key: key);

  @override
  State<EggSelectionScreen> createState() => _EggSelectionScreenState();
}

class _EggSelectionScreenState extends State<EggSelectionScreen> {
  FishType? _selectedFish; // 선택된 물고기 타입
  bool _isCreating = false; // 생성 중 로딩 상태

  // 각 물고기 타입별 상세 데이터 정의
  final Map<FishType, Map<String, dynamic>> _fishData = {
    FishType.goldfish: {
      'name': '금붕어',
      'emoji': '🟡',
      'color': const Color(0xFFFFD700),
      'description': '행운과 부를 가져다주는\n황금빛 물고기',
    },
    FishType.bluefish: {
      'name': '파랑이',
      'emoji': '🔵',
      'color': const Color(0xFF4169E1),
      'description': '깊은 바다의 지혜를\n품은 물고기',
    },
    FishType.redfish: {
      'name': '빨강이',
      'emoji': '🔴',
      'color': const Color(0xFFDC143C),
      'description': '열정과 용기가 넘치는\n붉은 물고기',
    },
    FishType.tropical: {
      'name': '열대어',
      'emoji': '🐠',
      'color': const Color(0xFFFF6B9D),
      'description': '화려한 색상의\n열대 물고기',
    },
    FishType.clownfish: {
      'name': '니모',
      'emoji': '🐡',
      'color': const Color(0xFFFF8C00),
      'description': '귀엽고 사교적인\n니모 친구',
    },
    FishType.dolphin: {
      'name': '돌고래',
      'emoji': '🐬',
      'color': const Color(0xFF00CED1),
      'description': '영리하고 빠른\n바다의 천재',
    },
  };

  /// [핵심 로직] 사용자 생성 및 메인 화면 이동
  Future<void> _createUser() async {
    if (_selectedFish == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('물고기를 선택해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final storage = StorageService();
      // 1. 초기 사용자 데이터 객체 생성
      final userData = storage.createInitialUser(
        _selectedFish!,
        widget.selectedCategories,
      );

      // 2. Provider를 통해 데이터 저장 및 상태 반영
      await context.read<AppProvider>().saveUserData(userData);

      if (!mounted) return;

      // 3. 메인 화면으로 이동 (뒤로가기를 할 수 없도록 pushReplacement 사용)
      Navigator.of(context).pushReplacementNamed('/main');

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 맵에 정의된 데이터들만 리스트로 가져와 런타임 에러를 방지합니다.
    final availableFishTypes = _fishData.keys.toList();

    return Scaffold(
      body: Container( // [주의] Container는 const를 사용하지 않습니다.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A3A52),
              Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // 제목 이콘
                const Text(
                  '🥚',
                  style: TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 24),
                const Text(
                  '물고기 알 선택',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '키우고 싶은 물고기를 선택하세요\n함께 퀘스트를 하며 성장합니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // 물고기 카드 목록
                Expanded(
                  child: ListView.builder(
                    itemCount: availableFishTypes.length,
                    itemBuilder: (context, index) {
                      final fishType = availableFishTypes[index];
                      final data = _fishData[fishType]!;
                      final isSelected = _selectedFish == fishType;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildFishCard(
                          fishType: fishType,
                          name: data['name'] as String,
                          emoji: data['emoji'] as String,
                          color: data['color'] as Color,
                          description: data['description'] as String,
                          isSelected: isSelected,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 시작 버튼 영역
                if (_isCreating)
                  const CircularProgressIndicator(
                    color: Color(0xFF4FC3F7),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _createUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC3F7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '시작하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 물고기 선택 카드 위젯
  Widget _buildFishCard({
    required FishType fishType,
    required String name,
    required String emoji,
    required Color color,
    required String description,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFish = fishType);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : const Color(0xFF1E2A3A).withOpacity(0.8),
          border: Border.all(
            color: isSelected ? color : Colors.white10,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // 물고기 이모지
            Text(
              emoji,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(width: 20),

            // 물고기 설명 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // 선택된 경우 체크 아이콘 표시
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 32,
              ),
          ],
        ),
      ),
    );
  }
}