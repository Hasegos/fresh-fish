import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final UserData userData;

  const SettingsScreen({super.key, required this.userData});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserData _userData;
  bool _isEditingNickname = false;
  final TextEditingController _nicknameController = TextEditingController();
  bool _showDeleteConfirm = false;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _nicknameController.text = _userData.nickname;
  }

  Future<void> _saveNickname() async {
    if (_nicknameController.text.trim().isEmpty) return;

    final updatedUser = _userData.copyWith(nickname: _nicknameController.text.trim());
    await StorageService.saveUserData(updatedUser);

    setState(() {
      _userData = updatedUser;
      _isEditingNickname = false;
    });
  }

  Future<void> _toggleNotifications() async {
    final updatedUser = _userData.copyWith(
      notificationsEnabled: !_userData.notificationsEnabled,
    );
    await StorageService.saveUserData(updatedUser);

    setState(() {
      _userData = updatedUser;
    });
  }

  Future<void> _logout() async {
    Navigator.pop(context, {'action': 'logout'});
  }

  Future<void> _deleteAccount() async {
    if (_showDeleteConfirm) {
      await StorageService.clearAll();
      if (mounted) {
        Navigator.pop(context, {'action': 'delete'});
      }
    } else {
      setState(() {
        _showDeleteConfirm = true;
      });
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showDeleteConfirm = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context, {'userData': _userData}),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '설정',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Profile Section
                    _buildSection(
                      icon: Icons.person,
                      title: '내 프로필',
                      child: _isEditingNickname
                          ? Column(
                              children: [
                                TextField(
                                  controller: _nicknameController,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    hintText: '닉네임 입력',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF3B82F6),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _nicknameController.text = _userData.nickname;
                                            _isEditingNickname = false;
                                          });
                                        },
                                        child: const Text('취소'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _saveNickname,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF3B82F6),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('저장'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '닉네임',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _userData.nickname,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _isEditingNickname = true;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF3B82F6),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: const Text('수정'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.only(top: 16),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Color(0xFFE5E7EB)),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            const Text(
                                              '레벨',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_userData.level}',
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF3B82F6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            const Text(
                                              '보유 골드',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_userData.gold} G',
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFF59E0B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Notifications Section
                    _buildSection(
                      icon: Icons.notifications,
                      title: '알림 설정',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '푸시 알림',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '매일 아침 9시에 미션 알림',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _userData.notificationsEnabled,
                            onChanged: (_) => _toggleNotifications(),
                            activeColor: const Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Account Management Section
                    _buildSection(
                      icon: Icons.info_outline,
                      title: '계정 관리',
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.logout,
                            title: '로그아웃',
                            onTap: _logout,
                          ),
                          const SizedBox(height: 12),
                          _buildSettingsTile(
                            icon: Icons.delete_outline,
                            title: _showDeleteConfirm
                                ? '정말 삭제하시겠습니까?'
                                : '회원 탈퇴',
                            subtitle: _showDeleteConfirm
                                ? '다시 클릭하면 모든 데이터가 삭제됩니다'
                                : null,
                            onTap: _deleteAccount,
                            isDestructive: true,
                            isWarning: _showDeleteConfirm,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Fish Quest v1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '나만의 수조 습관 트래커',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF3B82F6), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isWarning = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isWarning ? const Color(0xFFFEE2E2) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF1F2937),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
}