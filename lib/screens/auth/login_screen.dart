import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../app_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _isLoading = true);

    try {
      // TODO: FirebaseAuth 로그인 연결
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ 구글 로그인 UI용 핸들러 (지금은 UI/흐름만)
  Future<void> _onGoogleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // TODO: Google Sign-In + FirebaseAuth 연결
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;
      // 성공 시 메인으로
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('구글 로그인 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  void _goDevMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppScreen()),
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
                              color: AppColors.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('갓', style: TextStyle(fontSize: 44)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            '갓생어',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '갓생을 시작해요',
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
                              controller: _pwCtrl,
                              label: '비밀번호',
                              hint: '6자 이상',
                              icon: Icons.lock_outline,
                              obscure: _obscure,
                              suffix: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.isEmpty) return '비밀번호를 입력하세요';
                                if (value.length < 6) return '비밀번호는 6자 이상';
                                return null;
                              },
                              onSubmitted: (_) => _onLogin(),
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _onLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
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
                                  '로그인',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),

                            // 여기부터 추가: "또는" + 구글 로그인 버튼
                            const SizedBox(height: 14),
                            const _OrDivider(text: '또는'),
                            const SizedBox(height: 12),

                            _SocialButton(
                              onPressed: _isLoading ? null : _onGoogleLogin,
                              label: 'Google로 계속하기',
                              leading: Image.asset(
                                'assets/images/google_logo.png',
                                width: 20,
                                height: 20,
                              ),
                            ),

                            const SizedBox(height: 10),

                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                      content: Text('비밀번호 찾기(준비중)')),
                                );
                              },
                              child: const Text(
                                '비밀번호를 잊으셨나요?',
                                style:
                                TextStyle(color: AppColors.textSecondary),
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
                          '계정이 없으신가요?',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _goSignup,
                          child: const Text('회원가입'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _goDevMain,
                        child: const Text('DEV: 개발자용'),
                      ),
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
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: validator,
      onFieldSubmitted: onSubmitted,
    );
  }
}

// ✅ "또는" 구분선 위젯
class _OrDivider extends StatelessWidget {
  final String text;
  const _OrDivider({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.18), height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.18), height: 1),
        ),
      ],
    );
  }
}

// ✅ 소셜 로그인 버튼(구글 등) 공용 UI
class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget leading;

  const _SocialButton({
    required this.onPressed,
    required this.label,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.12),
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: Colors.white.withOpacity(0.18)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
