import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 하단 네비게이션 바 위젯
class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.task_alt,
                label: 'ToDos',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.schedule,
                label: 'Timer',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.calendar_month,
                label: 'Calendar',
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.menu,
                label: 'Menu',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF81E6D9).withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? const Color(0xFF81E6D9)
                      : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF81E6D9)
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 커스텀 네비게이션 바 (더 화려한 버전)
class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildFloatingNavItem(
              index: 0,
              icon: Icons.home,
              label: 'Home',
            ),
            _buildFloatingNavItem(
              index: 1,
              icon: Icons.task_alt,
              label: 'ToDos',
            ),
            _buildFloatingNavItem(
              index: 2,
              icon: Icons.schedule,
              label: 'Timer',
            ),
            _buildFloatingNavItem(
              index: 3,
              icon: Icons.calendar_month,
              label: 'Calendar',
            ),
            _buildFloatingNavItem(
              index: 4,
              icon: Icons.menu,
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Colors.white
                  : AppColors.textSecondary,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
