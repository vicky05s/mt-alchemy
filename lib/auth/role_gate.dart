import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';

/// Shows [child] only if the current user's role is in [allowed].
/// Otherwise shows [fallback] (or a simple "no access" message).
///
/// Example:
///   RoleGate(allowed: [UserRole.admin, UserRole.trainer], child: AdminScreen())
class RoleGate extends StatelessWidget {
  final List<String> allowed;
  final Widget child;
  final Widget? fallback;

  const RoleGate({
    super.key,
    required this.allowed,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isInitialising) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (auth.hasRole(allowed)) return child;
    return fallback ??
        Scaffold(
          appBar: AppBar(title: const Text('Access restricted')),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'You do not have access to this page. Please sign in with the correct account.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
  }
}
