// screens/decoration_shop_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../providers/user_data_provider.dart';
import '../../widgets/bottom_navigation.dart';

class DecorationShopScreen extends StatelessWidget {
  const DecorationShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context), // 👈 정의된 함수 호출
            Expanded(
              child: Consumer<UserDataProvider>(
                builder: (context, provider, child) {
                  final items = [
                    {'id': 'deco_01', 'name': '푸른 산호', 'price': 100, 'icon': '🪸'},
                    {'id': 'deco_02', 'name': '황금 보물상자', 'price': 500, 'icon': '🏴‍☠️'},
                    {'id': 'deco_03', 'name': '해초 숲', 'price': 50, 'icon': '🌿'},
                  ];

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final bool isOwned = provider.userData?.ownedDecorations.contains(item['id']) ?? false;

                      return _buildShopItemCard(context, item, isOwned); // 👈 정의된 함수 호출
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          print("Selected Tab Index: $index");
        },
      ),
    );
  }

  // --- 👇 누락되었던 위젯 함수 정의 부분 ---

  /// [How] 상단 헤더 영역을 구성합니다.
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.read<UserDataProvider>().backToMain(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          const Text(
            '🏪 Decoration Shop',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // [Why] 사용자가 현재 얼마를 가졌는지 보여주어야 구매 의사결정을 돕습니다.
          Consumer<UserDataProvider>(
            builder: (context, provider, child) => Text(
              '💰 ${provider.userData?.gold ?? 0}G',
              style: const TextStyle(
                color: AppColors.highlightPink,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [How] 개별 아이템 카드를 구성합니다.
  Widget _buildShopItemCard(BuildContext context, Map<String, dynamic> item, bool isOwned) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOwned ? AppColors.borderLight : AppColors.primaryPastel.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item['icon'] as String, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            item['name'] as String,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${item['price']} G',
            style: const TextStyle(color: AppColors.highlightPink),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isOwned
                ? null // 이미 소유한 경우 버튼 비활성화
                : () async {
              //에 정의된 구매 로직 호출
              final success = await context.read<UserDataProvider>().purchaseDecoration(
                  item['id'] as String,
                  item['price'] as int
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['name']} 구매 완료!'),
                    backgroundColor: AppColors.statusSuccess,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('골드가 부족합니다.'),
                    backgroundColor: AppColors.highlightPink,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isOwned ? AppColors.textTertiary : AppColors.primaryPastel,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isOwned ? '보유중' : '구매하기'),
          ),
        ],
      ),
    );
  }
}