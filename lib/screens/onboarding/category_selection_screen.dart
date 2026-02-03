import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 카테고리 선택 화면
class CategorySelectionScreen extends StatefulWidget {
  final Function(List<String>) onComplete;

  const CategorySelectionScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final List<String> _selectedCategories = [];

  final List<Map<String, String>> _categories = [
    {'name': '학업', 'icon': '📚', 'description': '공부와 학습'},
    {'name': '건강', 'icon': '💪', 'description': '운동과 건강관리'},
    {'name': '자기계발', 'icon': '🚀', 'description': '성장과 발전'},
    {'name': '생활', 'icon': '🏠', 'description': '일상 루틴'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // 제목
              const Text(
                '관심 카테고리 선택',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '최소 1개 이상 선택해주세요',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // 카테고리 목록
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategories.contains(category['name']);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildCategoryCard(
                        name: category['name']!,
                        icon: category['icon']!,
                        description: category['description']!,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedCategories.remove(category['name']);
                            } else {
                              _selectedCategories.add(category['name']!);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // 다음 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedCategories.isEmpty
                      ? null
                      : () => widget.onComplete(_selectedCategories),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPastel,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.textTertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    '다음 (${_selectedCategories.length}개 선택)',
                    style: const TextStyle(
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
    );
  }

  Widget _buildCategoryCard({
    required String name,
    required String icon,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPastel.withOpacity(0.12)
              : AppColors.surface,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPastel
                : AppColors.borderLight,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // 아이콘
            Text(
              icon,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 20),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 선택 표시
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: isSelected
                  ? AppColors.primaryPastel
                  : AppColors.textTertiary,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
