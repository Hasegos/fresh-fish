import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _emailCodeCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfirmCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;
  Gender _gender = Gender.none;
  bool _ageNotSelected = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _emailCodeCtrl.dispose();
    _pwCtrl.dispose();
    _pwConfirmCtrl.dispose();
    _nicknameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _isLoading = true);

    try {
      // TODO: FirebaseAuth 회원가입 연결
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 완료')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 18),

                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('가입', style: TextStyle(fontSize: 28)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            '회원가입',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '새 계정을 만들어 시작해요',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _Input(
                              controller: _emailCtrl,
                              label: '이메일',
                              hint: 'example@email.com',
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              suffix: TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('인증번호 발송(준비중)')),
                                        );
                                      },
                                child: const Text('인증번호 발송'),
                              ),
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return '이메일을 입력하세요';
                                if (!value.contains('@')) {
                                  return '올바른 이메일 형식이 아닙니다';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _Input(
                              controller: _emailCodeCtrl,
                              label: '이메일 인증',
                              hint: '인증번호 입력',
                              icon: Icons.verified_outlined,
                              keyboardType: TextInputType.number,
                              suffix: TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('이메일 인증(준비중)')),
                                        );
                                      },
                                child: const Text('인증하기'),
                              ),
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return '인증번호를 입력하세요';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _Input(
                              controller: _pwCtrl,
                              label: '비밀번호',
                              hint: '6자 이상',
                              icon: Icons.lock_outline,
                              obscure: _obscure,
                              suffix: IconButton(
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure ? Icons.visibility : Icons.visibility_off,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.isEmpty) return '비밀번호를 입력하세요';
                                if (value.length < 6) return '비밀번호는 6자 이상';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _Input(
                              controller: _pwConfirmCtrl,
                              label: '비밀번호 확인',
                              hint: '동일하게 입력',
                              icon: Icons.lock_outline,
                              obscure: _obscure,
                              validator: (v) {
                                final value = v ?? '';
                                if (value.isEmpty) return '비밀번호 확인을 입력하세요';
                                if (value != _pwCtrl.text) {
                                  return '비밀번호가 일치하지 않습니다';
                                }
                                return null;
                              },
                              onSubmitted: (_) => _onSignup(),
                            ),
                            const SizedBox(height: 12),
                            _Input(
                              controller: _nicknameCtrl,
                              label: '닉네임',
                              hint: '사용할 닉네임',
                              icon: Icons.person_outline,
                              suffix: TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('닉네임 중복체크(준비중)')),
                                        );
                                      },
                                child: const Text('중복체크'),
                              ),
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return '닉네임을 입력하세요';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _Input(
                                    controller: _ageCtrl,
                                    label: '나이',
                                    hint: '예: 25',
                                    icon: Icons.cake_outlined,
                                    keyboardType: TextInputType.number,
                                    enabled: !_ageNotSelected,
                                    validator: (v) {
                                      if (_ageNotSelected) return null;
                                      final value = (v ?? '').trim();
                                      if (value.isEmpty) return '나이를 입력하세요';
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    const Text(
                                      '선택 안 함',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Switch(
                                      value: _ageNotSelected,
                                      onChanged: (v) {
                                        setState(() {
                                          _ageNotSelected = v;
                                          if (v) _ageCtrl.clear();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _GenderSelector(
                              value: _gender,
                              onChanged: (next) => setState(() => _gender = next),
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _onSignup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        '회원가입',
                                        style: TextStyle(fontWeight: FontWeight.w700),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '이미 계정이 있나요?',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _goLogin,
                          child: const Text('로그인'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const _Input({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.enabled = true,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      enabled: enabled,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.10),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
      ),
      validator: validator,
      onFieldSubmitted: onSubmitted,
    );
  }
}

enum Gender { male, female, none }

class _GenderSelector extends StatelessWidget {
  final Gender value;
  final ValueChanged<Gender> onChanged;

  const _GenderSelector({
    required this.value,
    required this.onChanged,
  });

  String _label(Gender g) {
    switch (g) {
      case Gender.male:
        return '남자';
      case Gender.female:
        return '여자';
      case Gender.none:
        return '선택 안 함';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '성별',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _GenderChip(
                label: _label(Gender.male),
                selected: value == Gender.male,
                onTap: () => onChanged(Gender.male),
              ),
              const SizedBox(width: 8),
              _GenderChip(
                label: _label(Gender.female),
                selected: value == Gender.female,
                onTap: () => onChanged(Gender.female),
              ),
              const SizedBox(width: 8),
              _GenderChip(
                label: _label(Gender.none),
                selected: value == Gender.none,
                onTap: () => onChanged(Gender.none),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppColors.secondary
                  : Colors.white.withOpacity(0.24),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
