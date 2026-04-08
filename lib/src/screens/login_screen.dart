import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/providers/access_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.onLogin});

  final VoidCallback? onLogin;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce correo y contraseña.')),
      );
      return;
    }

    await ref
        .read(accessAuthActionProvider.notifier)
        .signIn(email: email, password: password);

    if (!mounted) {
      return;
    }

    final authAction = ref.read(accessAuthActionProvider);
    if (authAction.hasError) {
      return;
    }

    widget.onLogin?.call();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authAction = ref.watch(accessAuthActionProvider);
    final isLoading = authAction.isLoading;

    return LemaScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: 420,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      _Header(textTheme: textTheme),
                      const SizedBox(height: 28),
                      _LoginCard(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        passwordFocusNode: _passwordFocusNode,
                        obscurePassword: _obscurePassword,
                        onTogglePasswordVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        onSubmit: _submit,
                        isLoading: isLoading,
                        errorMessage: authAction.hasError
                            ? authAction.error.toString()
                            : null,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LEMA ACCESS',
          style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 10),
        Text('Iniciar sesión', style: textTheme.displayLarge),
        const SizedBox(height: 8),
        Text(
          'Accede con tu cuenta operativa.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
    required this.onSubmit,
    required this.isLoading,
    required this.errorMessage,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onSubmit;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      padding: const EdgeInsets.all(18),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Credenciales', style: textTheme.headlineMedium),
          const SizedBox(height: 18),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              hintText: 'staff@lema.io',
            ),
            onSubmitted: (_) => passwordFocusNode.requestFocus(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Contraseña',
              hintText: 'Introduce tu contraseña',
              suffixIcon: IconButton(
                onPressed: onTogglePasswordVisibility,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 18),
          LemaPrimaryButton(
            label: isLoading ? 'Entrando...' : 'Entrar',
            icon: isLoading ? Icons.hourglass_top : Icons.arrow_forward,
            onPressed: isLoading ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}
