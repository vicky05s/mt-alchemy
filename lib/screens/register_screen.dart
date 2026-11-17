import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/app_user.dart';
import '../auth/auth_provider.dart';
import '../auth/auth_widgets.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

enum RegType { individual, employer }

class RegisterScreen extends StatefulWidget {
  final RegType initialType;
  const RegisterScreen({super.key, this.initialType = RegType.individual});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _countries = [
    'Malaysia', 'Singapore', 'Indonesia', 'Thailand', 'Philippines',
    'Vietnam', 'Brunei', 'India', 'China', 'Other',
  ];
  static const _industries = [
    'Technology', 'Finance & Banking', 'Education', 'Healthcare',
    'Manufacturing', 'Retail & E-commerce', 'Hospitality',
    'Government / NGO', 'Other',
  ];
  static const _employeeRanges = ['1–10', '11–50', '51–200', '201–500', '500+'];

  static const _softRed = Color(0xFFFFB4AB);

  final _formKey = GlobalKey<FormState>();
  late RegType _type = widget.initialType;

  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _orgName = TextEditingController();
  final _regNo = TextEditingController();
  final _contact = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  String? _country;
  String? _industry;
  String? _employees;
  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _agree = false;
  bool _agreeError = false;

  bool get _isEmployer => _type == RegType.employer;

  @override
  void dispose() {
    for (final c in [
      _first, _last, _email, _phone, _orgName, _regNo, _contact, _password,
      _confirm,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ------------------------------------------------------------------ submit
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    auth.clearError();

    final valid = _formKey.currentState!.validate();
    if (!_agree) setState(() => _agreeError = true);
    if (!valid || !_agree) return;

    final ok = await auth.register(
      name: _isEmployer
          ? _contact.text
          : '${_first.text.trim()} ${_last.text.trim()}',
      email: _email.text,
      password: _password.text,
      role: _isEmployer ? UserRole.employer : UserRole.individual,
      extra: {
        'phone': _phone.text.trim(),
        'country': _country,
        if (_isEmployer) ...{
          'organizationName': _orgName.text.trim(),
          'registrationNumber': _regNo.text.trim(),
          'industry': _industry,
          'employeeCount': _employees,
        } else ...{
          'firstName': _first.text.trim(),
          'lastName': _last.text.trim(),
        },
      },
    );
    if (!mounted || !ok) return;

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    messenger.showSnackBar(
      const SnackBar(
          content: Text('Registration success. Welcome to MT Alchemy!')),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ------------------------------------------------------------ field helpers
  InputDecoration _dec(String hint, {Widget? suffix}) {
    OutlineInputBorder border(Color c, [double w = 0]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: w == 0
          ? BorderSide.none
          : BorderSide(color: c, width: w),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9AA3B2), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: border(Colors.white),
      enabledBorder: border(Colors.white),
      focusedBorder: border(AppTheme.softYellow, 2),
      errorBorder: border(_softRed, 1.5),
      focusedErrorBorder: border(_softRed, 2),
      errorStyle: const TextStyle(color: _softRed),
    );
  }

  Widget _labeled(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.softYellow,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        field,
      ],
    );
  }

  Widget _text(
      String label,
      TextEditingController controller, {
        String? hint,
        TextInputType? keyboard,
        String? Function(String?)? validator,
      }) {
    return _labeled(
      label,
      TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: _dec(hint ?? ''),
        validator: validator ?? (v) => Validators.required(v, label),
      ),
    );
  }

  Widget _dropdown(
      String label,
      List<String> items,
      String? value,
      ValueChanged<String?> onChanged,
      ) {
    return _labeled(
      label,
      DropdownButtonFormField<String>(
        key: ValueKey('$label-${_type.name}'),
        initialValue: value,
        isExpanded: true,
        decoration: _dec('Select'),
        items: [
          for (final i in items) DropdownMenuItem(value: i, child: Text(i)),
        ],
        onChanged: onChanged,
        validator: (v) => v == null ? '$label is required' : null,
      ),
    );
  }

  Widget _password2(
      String label,
      TextEditingController controller,
      bool hidden,
      VoidCallback toggle,
      String? Function(String?) validator,
      ) {
    return _labeled(
      label,
      TextFormField(
        controller: controller,
        obscureText: hidden,
        decoration: _dec(
          '••••••••',
          suffix: IconButton(
            icon: Icon(
              hidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppTheme.greyText,
              size: 20,
            ),
            onPressed: toggle,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _pair(Widget a, Widget b, bool twoCol) {
    if (!twoCol) {
      return Column(children: [a, const SizedBox(height: 16), b]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 16),
        Expanded(child: b),
      ],
    );
  }

  Widget _gap() => const SizedBox(height: 12);

  // ------------------------------------------------------------- left panel
  Widget _leftPanel() {
    Widget ring(double size, double alpha) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );

    const sidePad = 56.0;

    return Container(
      color: AppTheme.deepBlue,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth =
          (constraints.maxWidth - sidePad * 2).clamp(280.0, 560.0);
          return Stack(
            children: [
              // gold tab: same left edge as the headline
              Positioned(
                top: 0,
                left: sidePad,
                child: Container(
                  width: 36,
                  height: 84,
                  color: AppTheme.softYellow,
                ),
              ),
              // whole block is centred vertically, like the form on the right
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: sidePad, vertical: 24),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Let's Make\nit Happen\nTogether!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Master human intelligence in a rapidly evolving AI-driven world.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 36),
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ring(300, 0.06),
                                ring(236, 0.10),
                                ClipOval(
                                  child: SizedBox(
                                    width: 170,
                                    height: 170,
                                    child: Image.asset(
                                      'assets/images/team_collaboration.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.white24,
                                        child: const Icon(
                                          Icons.auto_awesome_rounded,
                                          color: AppTheme.softYellow,
                                          size: 64,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------ right panel
  Widget _rightPanel(bool split) {
    final auth = context.watch<AuthProvider>();

    final vPad = split ? 16.0 : 16.0;
    return LayoutBuilder(
      builder: (context, outer) => SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: split ? 48 : 20,
          vertical: vPad,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: outer.maxHeight - vPad * 2),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final twoCol = constraints.maxWidth > 480;
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // top bar: brand (left) + sign-in link (right)
                        Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              tooltip: 'Back',
                            ),
                            const Text(
                              'MT',
                              style: TextStyle(
                                color: AppTheme.softYellow,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              ' Alchemy',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Already have an account? ',
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 13)),
                                      InkWell(
                                        onTap: _goToLogin,
                                        child: const Text(
                                          'Sign in here!',
                                          style: TextStyle(
                                            color: AppTheme.softYellow,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            decoration: TextDecoration.underline,
                                            decorationColor: AppTheme.softYellow,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Create An Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Individual / Employer toggle
                        SegmentedButton<RegType>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: RegType.individual,
                              icon: Icon(Icons.person_outline),
                              label: Text('Individual'),
                            ),
                            ButtonSegment(
                              value: RegType.employer,
                              icon: Icon(Icons.business_outlined),
                              label: Text('Employer'),
                            ),
                          ],
                          selected: {_type},
                          onSelectionChanged: (s) => setState(() {
                            _type = s.first;
                            _country = null;
                            _industry = null;
                            _employees = null;
                            _agreeError = false;
                            _formKey.currentState?.reset();
                          }),
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            selectedBackgroundColor: AppTheme.softYellow,
                            selectedForegroundColor: AppTheme.deepBlue,
                            side: const BorderSide(color: Colors.white38),
                          ),
                        ),
                        const SizedBox(height: 14),

                        if (auth.error != null) ...[
                          ErrorBanner(auth.error!),
                          const SizedBox(height: 16),
                        ],

                        // ---- fields
                        if (_isEmployer) ...[
                          _pair(
                            _text('Company Name', _orgName,
                                hint: 'e.g. ABC Sdn Bhd'),
                            _text(
                              'Company Registration No.',
                              _regNo,
                              hint: 'e.g. 202001012345',
                              validator: (v) {
                                final r = Validators.required(
                                    v, 'Registration number');
                                if (r != null) return r;
                                return v!.trim().length < 5
                                    ? 'Enter a valid registration number'
                                    : null;
                              },
                            ),
                            twoCol,
                          ),
                          _gap(),
                          _pair(
                            _dropdown('Industry', _industries, _industry,
                                    (v) => setState(() => _industry = v)),
                            _dropdown('Number of Employees', _employeeRanges,
                                _employees, (v) => setState(() => _employees = v)),
                            twoCol,
                          ),
                          _gap(),
                          _pair(
                            _text('Contact Person', _contact,
                                hint: 'Full name'),
                            _text('Business Email', _email,
                                hint: 'name@company.com',
                                keyboard: TextInputType.emailAddress,
                                validator: Validators.email),
                            twoCol,
                          ),
                        ] else ...[
                          _pair(
                            _text('First Name', _first, hint: 'First name'),
                            _text('Last Name', _last, hint: 'Last name'),
                            twoCol,
                          ),
                          _gap(),
                          _text('Email', _email,
                              hint: 'name@email.com',
                              keyboard: TextInputType.emailAddress,
                              validator: Validators.email),
                        ],
                        _gap(),
                        _pair(
                          _text('Phone Number', _phone,
                              hint: '+60 12 345 6789',
                              keyboard: TextInputType.phone,
                              validator: Validators.phone),
                          _dropdown('Country', _countries, _country,
                                  (v) => setState(() => _country = v)),
                          twoCol,
                        ),
                        _gap(),
                        _pair(
                          _password2(
                            'Create Password',
                            _password,
                            _hidePassword,
                                () => setState(() => _hidePassword = !_hidePassword),
                            Validators.password,
                          ),
                          _password2(
                            'Confirm Password',
                            _confirm,
                            _hideConfirm,
                                () => setState(() => _hideConfirm = !_hideConfirm),
                                (v) => v != _password.text
                                ? 'Passwords do not match'
                                : null,
                          ),
                          twoCol,
                        ),
                        const SizedBox(height: 8),

                        // ---- terms
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agree,
                              activeColor: AppTheme.softYellow,
                              checkColor: AppTheme.deepBlue,
                              side: const BorderSide(
                                  color: Colors.white, width: 1.5),
                              onChanged: (v) => setState(() {
                                _agree = v ?? false;
                                if (_agree) _agreeError = false;
                              }),
                            ),
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13),
                                    children: [
                                      TextSpan(
                                          text:
                                          'Creating your account and you accepting '),
                                      TextSpan(
                                        text: 'Terms & Conditions.',
                                        style: TextStyle(
                                          color: AppTheme.softYellow,
                                          fontWeight: FontWeight.w800,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppTheme.softYellow,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_agreeError)
                          const Padding(
                            padding: EdgeInsets.only(left: 12, bottom: 4),
                            child: Text(
                              'Please accept the terms to continue',
                              style: TextStyle(color: _softRed, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 6),

                        // ---- submit
                        SizedBox(
                          width: twoCol ? 300 : double.infinity,
                          child: ElevatedButton(
                            onPressed: auth.busy ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.softYellow,
                              foregroundColor: AppTheme.deepBlue,
                              disabledBackgroundColor: Colors.white24,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            child: auth.busy
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.deepBlue),
                            )
                                : Text(
                              _isEmployer
                                  ? 'Register Organisation'
                                  : 'Create Account',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '© 2026 MT Alchemy. All rights reserved.',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final split = constraints.maxWidth >= 900;
            if (!split) return _rightPanel(false);
            return Row(
              children: [
                Expanded(flex: 5, child: _leftPanel()),
                Expanded(flex: 6, child: _rightPanel(true)),
              ],
            );
          },
        ),
      ),
    );
  }
}