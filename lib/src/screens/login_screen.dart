import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/failure.dart';
import '../core/rpc_exception.dart';
import '../providers/auth_providers.dart';
import '../providers/bootstrap_providers.dart' as bootstrap;
import '../providers/profile_providers.dart' as profile;
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

enum AccessAuthStep { email, password, signup, completion }

enum _UsernameAvailabilityState {
  idle,
  checking,
  available,
  taken,
  invalid,
  error,
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.onLogin,
    this.initialStep = AccessAuthStep.email,
    this.initialEmail,
  });

  final VoidCallback? onLogin;
  final AccessAuthStep initialStep;
  final String? initialEmail;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _displayNameFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _signupPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  Timer? _usernameDebounce;
  int _usernameCheckGeneration = 0;

  late AccessAuthStep _step;
  String? _statusMessage;
  bool _statusIsError = false;
  bool _isCheckingEmail = false;
  _UsernameAvailabilityState _usernameAvailabilityState =
      _UsernameAvailabilityState.idle;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    _emailController.addListener(_submitAutofilledCredentials);
    _passwordController.addListener(_submitAutofilledCredentials);
    final initialEmail = widget.initialEmail?.trim();
    if (initialEmail != null && initialEmail.isNotEmpty) {
      _emailController.text = initialEmail;
    }
  }

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _displayNameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _signupPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  String get _resolvedEmail {
    final initialEmail = widget.initialEmail?.trim();
    if (initialEmail != null && initialEmail.isNotEmpty) {
      return initialEmail;
    }

    return _emailController.text.trim();
  }

  bool get _isSignupStep => _step == AccessAuthStep.signup;

  void _resetNotifierState() {
    ref.read(accessAuthActionProvider.notifier).reset();
  }

  void _clearStatus() {
    _resetNotifierState();
    setState(() {
      _statusMessage = null;
      _statusIsError = false;
    });
  }

  void _setStep(AccessAuthStep step) {
    _usernameDebounce?.cancel();
    _resetNotifierState();
    setState(() {
      _step = step;
      _statusMessage = null;
      _statusIsError = false;
      if (step == AccessAuthStep.email) {
        _passwordController.clear();
        _displayNameController.clear();
        _usernameController.clear();
        _confirmPasswordController.clear();
        _usernameAvailabilityState = _UsernameAvailabilityState.idle;
      } else if (step == AccessAuthStep.password) {
        _passwordController.clear();
        _displayNameController.clear();
        _usernameController.clear();
        _confirmPasswordController.clear();
        _usernameAvailabilityState = _UsernameAvailabilityState.idle;
      } else if (step == AccessAuthStep.signup ||
          step == AccessAuthStep.completion) {
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
      if (!_isSignupOrCompletion(step)) {
        _usernameAvailabilityState = _UsernameAvailabilityState.idle;
      }
    });
  }

  bool _isSignupOrCompletion(AccessAuthStep step) {
    return step == AccessAuthStep.signup || step == AccessAuthStep.completion;
  }

  void _showStatus(String message, {bool isError = true}) {
    setState(() {
      _statusMessage = message;
      _statusIsError = isError;
    });
  }

  String _readErrorMessage(Object error) {
    if (error is AccessFailure) {
      return error.message;
    }

    if (error is AccessRpcException) {
      return error.message;
    }

    return error.toString();
  }

  bool _isValidEmailFormat(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }

  void _submitAutofilledCredentials() {
    if (_step != AccessAuthStep.email ||
        _isCheckingEmail ||
        _passwordController.text.isEmpty ||
        !_isValidEmailFormat(_emailController.text)) {
      return;
    }

    _submitEmail();
  }

  bool _isValidUsernameFormat(String username) {
    return RegExp(
      r'^[a-z0-9](?:[a-z0-9-]{1,28}[a-z0-9])$',
    ).hasMatch(username.trim());
  }

  String? _passwordRequirementsError(String password) {
    final missing = [
      if (password.length < 6) 'al menos 6 caracteres',
      if (!RegExp(r'[A-Z]').hasMatch(password)) 'una mayúscula',
      if (!RegExp(r'\d').hasMatch(password)) 'un número',
    ];

    if (missing.isEmpty) {
      return null;
    }

    return 'Falta en la contraseña: ${missing.join(', ')}.';
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();

    if (!_isValidEmailFormat(email)) {
      _showStatus('Introduce un correo electrónico válido.');
      return;
    }

    _resetNotifierState();
    setState(() {
      _isCheckingEmail = true;
      _statusMessage = null;
      _statusIsError = false;
    });

    try {
      final registered = await ref
          .read(accessAuthActionProvider.notifier)
          .checkEmailRegistration(email);
      if (!mounted) {
        return;
      }

      if (!registered) {
        _passwordController.clear();
      }
      setState(() {
        _isCheckingEmail = false;
        _step = registered ? AccessAuthStep.password : AccessAuthStep.signup;
        _statusMessage = null;
        _statusIsError = false;
      });
      if (registered) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _step == AccessAuthStep.password) {
            _passwordFocusNode.requestFocus();
            if (_passwordController.text.isNotEmpty) {
              _submitPassword();
            }
          }
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCheckingEmail = false;
      });
      _showStatus(_readErrorMessage(error));
    }
  }

  Future<void> _submitPassword() async {
    final email = _resolvedEmail;
    final password = _passwordController.text;

    if (email.isEmpty) {
      _setStep(AccessAuthStep.email);
      return;
    }

    if (password.isEmpty) {
      _showStatus('Introduce tu contraseña para continuar.');
      return;
    }

    _resetNotifierState();

    try {
      final response = await ref
          .read(accessAuthActionProvider.notifier)
          .signIn(email: email, password: password);
      if (!mounted) {
        return;
      }

      if (response.session != null) {
        widget.onLogin?.call();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showStatus(_readErrorMessage(error));
    }
  }

  Future<void> _submitSignupOrCompletion() async {
    final email = _resolvedEmail;
    final displayName = _displayNameController.text.trim();
    final username = _usernameController.text.trim();

    if (displayName.isEmpty) {
      _showStatus('Introduce el nombre que verá el equipo.');
      return;
    }

    if (username.isEmpty) {
      _showStatus('Introduce un nombre de usuario.');
      return;
    }

    if (!_isValidUsernameFormat(username)) {
      _showStatus(
        'El nombre de usuario debe tener 3-30 caracteres y solo puede usar minúsculas, números y guiones.',
      );
      setState(() {
        _usernameAvailabilityState = _UsernameAvailabilityState.invalid;
      });
      return;
    }

    if (_isSignupStep) {
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;
      final passwordError = _passwordRequirementsError(password);

      if (passwordError != null) {
        _showStatus(passwordError);
        return;
      }

      if (password != confirmPassword) {
        _showStatus('Las contraseñas no coinciden.');
        return;
      }
    }

    if (_usernameAvailabilityState == _UsernameAvailabilityState.taken) {
      _showStatus('Ese nombre de usuario ya está en uso.');
      return;
    }

    if (_usernameAvailabilityState == _UsernameAvailabilityState.checking) {
      _showStatus('Estamos comprobando el nombre de usuario.');
      return;
    }

    final available = await _checkUsernameAvailability(username);
    if (!mounted) {
      return;
    }

    if (available == null) {
      _showStatus(
        'No se ha podido comprobar el nombre de usuario ahora mismo.',
      );
      setState(() {
        _usernameAvailabilityState = _UsernameAvailabilityState.error;
      });
      return;
    }

    if (!available) {
      _showStatus('Ese nombre de usuario ya está en uso.');
      setState(() {
        _usernameAvailabilityState = _UsernameAvailabilityState.taken;
      });
      return;
    }

    _resetNotifierState();

    try {
      if (_isSignupStep) {
        final response = await ref
            .read(accessAuthActionProvider.notifier)
            .signUp(
              email: email,
              password: _passwordController.text,
              displayName: displayName,
              username: username,
            );
        if (!mounted) {
          return;
        }

        if (response.session != null) {
          _invalidateBootstrapState();
          widget.onLogin?.call();
          return;
        }

        _showStatus(
          'Cuenta creada. Revisa tu correo para terminar de entrar.',
          isError: false,
        );
        return;
      }

      await ref
          .read(accessAuthActionProvider.notifier)
          .completeProfile(displayName: displayName, username: username);
      if (!mounted) {
        return;
      }

      _invalidateBootstrapState();
      widget.onLogin?.call();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showStatus(_readErrorMessage(error));
    }
  }

  void _invalidateBootstrapState() {
    ref.invalidate(bootstrap.accessBootstrapProvider);
    ref.invalidate(profile.accessMeProvider);
  }

  Future<bool?> _checkUsernameAvailability(String username) async {
    final normalized = username.trim();

    if (!_isValidUsernameFormat(normalized)) {
      if (!mounted) {
        return false;
      }

      setState(() {
        _usernameAvailabilityState = _UsernameAvailabilityState.invalid;
      });
      return false;
    }

    final currentGeneration = ++_usernameCheckGeneration;
    if (!mounted) {
      return false;
    }

    setState(() {
      _usernameAvailabilityState = _UsernameAvailabilityState.checking;
    });

    try {
      final available = await ref
          .read(accessAuthActionProvider.notifier)
          .checkUsernameAvailability(username: normalized);
      if (!mounted || currentGeneration != _usernameCheckGeneration) {
        return null;
      }

      setState(() {
        _usernameAvailabilityState = available
            ? _UsernameAvailabilityState.available
            : _UsernameAvailabilityState.taken;
      });
      return available;
    } catch (_) {
      if (!mounted || currentGeneration != _usernameCheckGeneration) {
        return null;
      }

      setState(() {
        _usernameAvailabilityState = _UsernameAvailabilityState.error;
      });
      return null;
    }
  }

  void _scheduleUsernameCheck(String value) {
    _usernameDebounce?.cancel();
    _clearStatus();

    final normalized = value.trim().toLowerCase();
    if (_usernameController.text != normalized) {
      _usernameController.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
    if (normalized.isEmpty) {
      setState(() {
        _usernameAvailabilityState = _UsernameAvailabilityState.idle;
      });
      return;
    }

    if (!_isValidUsernameFormat(normalized)) {
      setState(() {
        _usernameAvailabilityState = _UsernameAvailabilityState.invalid;
      });
      return;
    }

    setState(() {
      _usernameAvailabilityState = _UsernameAvailabilityState.checking;
    });

    _usernameDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted || !_isSignupOrCompletion(_step)) {
        return;
      }

      _checkUsernameAvailability(normalized);
    });
  }

  Widget _buildEmailStep() {
    return _AuthStepCard(
      title: 'Introduce tu correo',
      body: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'staff@lema.club',
              ),
              onChanged: (_) => _clearStatus(),
              onSubmitted: (_) => _submitEmail(),
            ),
            Offstage(
              child: TextField(
                key: const Key('email-autofill-password'),
                controller: _passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
              ),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 12),
              _StatusMessage(message: _statusMessage!, isError: _statusIsError),
            ],
            const SizedBox(height: 18),
            LemaPrimaryButton(
              label: _isCheckingEmail ? 'Comprobando...' : 'Continuar',
              icon: _isCheckingEmail
                  ? Icons.hourglass_top
                  : Icons.arrow_forward,
              onPressed: _isCheckingEmail ? null : _submitEmail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStep(bool isSubmitting) {
    return _AuthStepCard(
      title: 'Introduce tu contraseña',
      headerBadge: _EmailBadge(email: _resolvedEmail),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              hintText: 'Introduce tu contraseña',
            ),
            onChanged: (_) => _clearStatus(),
            onSubmitted: (_) => _submitPassword(),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 12),
            _StatusMessage(message: _statusMessage!, isError: _statusIsError),
          ],
          const SizedBox(height: 18),
          LemaPrimaryButton(
            label: isSubmitting ? 'Entrando...' : 'Entrar',
            icon: isSubmitting ? Icons.hourglass_top : Icons.arrow_forward,
            onPressed: isSubmitting ? null : _submitPassword,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupStep(bool isSubmitting) {
    return _AuthStepCard(
      headerBadge: _EmailBadge(email: _resolvedEmail),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _displayNameController,
            focusNode: _displayNameFocusNode,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            decoration: const InputDecoration(
              labelText: 'Nombre visible',
              hintText: 'Equipo LEMA',
            ),
            onChanged: (_) => _clearStatus(),
            onSubmitted: (_) => _usernameFocusNode.requestFocus(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _usernameController,
            focusNode: _usernameFocusNode,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: InputDecoration(
              labelText: 'Nombre de usuario',
              hintText: 'equipo-lema',
              errorText: _usernameErrorText,
              errorMaxLines: 3,
              suffixIcon: _usernameSuffixIcon,
            ),
            onChanged: _scheduleUsernameCheck,
            onSubmitted: (_) => _signupPasswordFocusNode.requestFocus(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            focusNode: _signupPasswordFocusNode,
            obscureText: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              hintText: 'Crea una contraseña',
            ),
            onChanged: (_) => _clearStatus(),
            onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(
              labelText: 'Confirmar contraseña',
              hintText: 'Repite la contraseña',
            ),
            onChanged: (_) => _clearStatus(),
            onSubmitted: (_) => _submitSignupOrCompletion(),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 12),
            _StatusMessage(message: _statusMessage!, isError: _statusIsError),
          ],
          const SizedBox(height: 18),
          LemaPrimaryButton(
            label: isSubmitting ? 'Creando...' : 'Crear cuenta',
            icon: isSubmitting ? Icons.hourglass_top : Icons.person_add_alt_1,
            onPressed: isSubmitting ? null : _submitSignupOrCompletion,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStep(bool isSubmitting) {
    return _AuthStepCard(
      headerBadge: _EmailBadge(email: _resolvedEmail),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _displayNameController,
            focusNode: _displayNameFocusNode,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            decoration: const InputDecoration(
              labelText: 'Nombre visible',
              hintText: 'Equipo LEMA',
            ),
            onChanged: (_) => _clearStatus(),
            onSubmitted: (_) => _usernameFocusNode.requestFocus(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _usernameController,
            focusNode: _usernameFocusNode,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.username],
            decoration: InputDecoration(
              labelText: 'Nombre de usuario',
              hintText: 'equipo-lema',
              errorText: _usernameErrorText,
              errorMaxLines: 3,
              suffixIcon: _usernameSuffixIcon,
            ),
            onChanged: _scheduleUsernameCheck,
            onSubmitted: (_) => _submitSignupOrCompletion(),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 12),
            _StatusMessage(message: _statusMessage!, isError: _statusIsError),
          ],
          const SizedBox(height: 18),
          LemaPrimaryButton(
            label: isSubmitting ? 'Completando...' : 'Completar perfil',
            icon: isSubmitting
                ? Icons.hourglass_top
                : Icons.verified_user_outlined,
            onPressed: isSubmitting ? null : _submitSignupOrCompletion,
          ),
        ],
      ),
    );
  }

  String? get _usernameErrorText {
    return switch (_usernameAvailabilityState) {
      _UsernameAvailabilityState.taken =>
        'Ese nombre de usuario ya está en uso.',
      _UsernameAvailabilityState.invalid =>
        'El nombre de usuario debe tener 3-30 caracteres y solo puede usar minúsculas, números y guiones.',
      _UsernameAvailabilityState.error =>
        'No se ha podido comprobar la disponibilidad ahora mismo.',
      _ => null,
    };
  }

  Widget? get _usernameSuffixIcon {
    return switch (_usernameAvailabilityState) {
      _UsernameAvailabilityState.checking => const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      _UsernameAvailabilityState.available => const Icon(
        Icons.check_circle_outline,
        color: AppColors.success,
      ),
      _UsernameAvailabilityState.taken ||
      _UsernameAvailabilityState.invalid ||
      _UsernameAvailabilityState.error => const Icon(
        Icons.error_outline,
        color: AppColors.error,
      ),
      _UsernameAvailabilityState.idle => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authAction = ref.watch(accessAuthActionProvider);
    final isSubmitting = authAction.isLoading;
    final showBack =
        _step == AccessAuthStep.password || _step == AccessAuthStep.signup;
    const animDuration = Duration(milliseconds: 300);
    const animCurve = Curves.easeInOut;

    return LemaScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: 440,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedSize(
                        duration: animDuration,
                        curve: animCurve,
                        child: SizedBox(
                          width: double.infinity,
                          child: showBack
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        size: 20,
                                      ),
                                      label: const Text('Cambiar correo'),
                                      onPressed: () =>
                                          _setStep(AccessAuthStep.email),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                      _Header(textTheme: textTheme, step: _step),
                      const SizedBox(height: 24),
                      AnimatedSize(
                        duration: animDuration,
                        curve: animCurve,
                        child: AnimatedSwitcher(
                          duration: animDuration,
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: KeyedSubtree(
                            key: ValueKey(_step),
                            child: SizedBox(
                              width: double.infinity,
                              child: switch (_step) {
                                AccessAuthStep.email => _buildEmailStep(),
                                AccessAuthStep.password => _buildPasswordStep(
                                  isSubmitting,
                                ),
                                AccessAuthStep.signup => _buildSignupStep(
                                  isSubmitting,
                                ),
                                AccessAuthStep.completion =>
                                  _buildCompletionStep(isSubmitting),
                              },
                            ),
                          ),
                        ),
                      ),
                      AnimatedSize(
                        duration: animDuration,
                        curve: animCurve,
                        child: isSubmitting
                            ? const Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: _SubmittingHint(),
                              )
                            : const SizedBox.shrink(),
                      ),
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
  const _Header({required this.textTheme, required this.step});

  final TextTheme textTheme;
  final AccessAuthStep step;

  @override
  Widget build(BuildContext context) {
    final (String title, String? subtitle) = switch (step) {
      AccessAuthStep.email => ('Empecemos', null),
      AccessAuthStep.password => ('Contraseña', null),
      AccessAuthStep.signup => (
        'Alta',
        'Crea el acceso con tu nombre visible y tu nombre de usuario.',
      ),
      AccessAuthStep.completion => (
        'Completa tu perfil',
        'La cuenta existe, pero el perfil todavía no está completo.',
      ),
    };

    const animDuration = Duration(milliseconds: 300);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LEMA ACCESS',
          style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: animDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            final offsetAnimation =
                Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offsetAnimation, child: child),
            );
          },
          child: SizedBox(
            key: ValueKey(title),
            width: double.infinity,
            child: Text(title, style: textTheme.displayLarge),
          ),
        ),
        AnimatedSize(
          duration: animDuration,
          curve: Curves.easeInOut,
          child: subtitle != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AnimatedSwitcher(
                    duration: animDuration,
                    child: SizedBox(
                      key: ValueKey(subtitle),
                      width: double.infinity,
                      child: Text(
                        subtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _AuthStepCard extends StatelessWidget {
  const _AuthStepCard({
    this.title,
    required this.body,
    this.headerBadge,
  });

  final String? title;
  final Widget body;
  final Widget? headerBadge;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      padding: const EdgeInsets.all(18),
      color: AppColors.surface,
      borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(title!, style: textTheme.headlineMedium),
            ),
          if (headerBadge case final badge?) ...[
            badge,
            const SizedBox(height: 18),
          ],
          body,
        ],
      ),
    );
  }
}

class _EmailBadge extends StatelessWidget {
  const _EmailBadge({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return LemaTag(
      label: email.isEmpty ? 'Correo pendiente' : email,
      icon: Icons.mail_outline,
      color: AppColors.surfaceHigh,
      textColor: AppColors.secondary,
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = isError ? AppColors.error : AppColors.secondary;

    return LemaPanel(
      color: AppColors.surfaceLow,
      borderColor: accent.withValues(alpha: 0.28),
      padding: const EdgeInsets.all(14),
      child: Text(
        message,
        style: textTheme.bodyMedium?.copyWith(color: accent),
      ),
    );
  }
}

class _SubmittingHint extends StatelessWidget {
  const _SubmittingHint();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
        const SizedBox(width: 10),
        Text(
          'Procesando la sesión...',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}
