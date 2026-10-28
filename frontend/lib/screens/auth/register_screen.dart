import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/validators.dart';
import '../../utils/l10n.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Focus nodes for Enter-to-next traversal
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(_userCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Error'), backgroundColor: context.appColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LangProvider>().t;
    final loading = context.watch<AuthProvider>().status == AuthStatus.loading;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.business_center_rounded,
                      color: c.onPrimary, size: IconSize.xl),
                ),
                const SizedBox(height: Spacing.xl),
                Text(t.register, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: c.textPrimary)),
                const SizedBox(height: 6),
                Text(t.registerSub, style: TextStyle(fontSize: 13, color: c.textSecondary)),
                const SizedBox(height: Spacing.xxxl),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Username — Enter → focus password
                      TextFormField(
                        controller: _userCtrl,
                        decoration: InputDecoration(
                            labelText: t.username,
                            prefixIcon: Icon(Icons.person_outline, color: c.textSecondary)),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _passFocus.requestFocus(),
                        validator: Validators.username,
                      ),
                      const SizedBox(height: Spacing.md),

                      // Password — Enter → focus confirm
                      TextFormField(
                        controller: _passCtrl,
                        focusNode: _passFocus,
                        decoration: InputDecoration(
                          labelText: t.password,
                          prefixIcon: Icon(Icons.lock_outline, color: c.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: IconSize.medium,
                              color: c.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                        validator: Validators.password,
                      ),
                      const SizedBox(height: Spacing.md),

                      // Confirm password — Enter → submit
                      TextFormField(
                        controller: _confirmCtrl,
                        focusNode: _confirmFocus,
                        decoration: InputDecoration(
                          labelText: t.confirmPassword,
                          prefixIcon: Icon(Icons.lock_outline, color: c.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: IconSize.medium,
                              color: c.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) => v != _passCtrl.text ? t.passwordMismatch : null,
                      ),
                      const SizedBox(height: Spacing.xl),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: loading ? null : _submit,
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : Text(t.register, style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.hasAccount, style: TextStyle(fontSize: 13, color: c.textSecondary)),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: Text(t.signIn),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
