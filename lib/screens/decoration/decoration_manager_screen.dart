// screens/decoration_manager_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_data_provider.dart';
import '../../widgets/bottom_navigation.dart';

/// 장식 관리 화면
class DecorationManagerScreen extends StatelessWidget {
  const DecorationManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1628), Color(0xFF1B263B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context), // 👈 정의된 함수 호출

              Expanded(
                child: Consumer<UserDataProvider>(
                  builder: (context, provider, child) {
                    // [Why] 소유한 장식 아이템 ID 리스트를 가져옵니다.
                    final ownedIds = provider.userData?.ownedDecorations ?? [];

                    // [Simple Example] 아이템 정보 데이터베이스 (실제로는 별도 파일로 관리 권장)
                    final allItems = [
                      {'id': 'deco_01', 'name': '푸른 산호', 'icon': '🪸'},
                      {'id': 'deco_02', 'name': '황금 보물상자', 'icon': '🏴‍☠️'},
                      {'id': 'deco_03', 'name': '해초 숲', 'icon': '🌿'},
                    ];

                    // [How] 내가 가진 아이템들만 필터링합니다.
                    final myItems = allItems.where((item) => ownedIds.contains(item['id'])).toList();

                    if (myItems.isEmpty) {
                      return const Center(
                        child: Text(
                          '보유 중인 장식이 없습니다.\n상점에서 장식을 구매해 보세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF778DA9), fontSize: 16),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: myItems.length,
                      itemBuilder: (context, index) {
                        return _buildOwnedItemCard(context, myItems[index]);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      // [Critical Fix] BottomNavigation에 필수 파라미터를 전달합니다.
      bottomNavigationBar: BottomNavigation(
        currentIndex: 3, // 장식 관리 탭의 인덱스 번호 (임의 설정)
        onTap: (index) {
          // 탭 전환 로직 (예: Navigator push 등)
          print("매니저 화면에서 탭 클릭: $index");
        },
      ),
    );
  }

  // --- 👇 위젯 함수 정의 부분 ---

  /// 상단 헤더
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.read<UserDataProvider>().backToMain(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            '🎨 Decoration Manager',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 보유 아이템 카드
  Widget _buildOwnedItemCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item['icon'] as String, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            item['name'] as String,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // [How] 아이템을 수족관에 적용하는 로직 (예시)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item['name']} 장착 완료!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('장착하기'),
          ),
        ],
      ),
    );
  }
}