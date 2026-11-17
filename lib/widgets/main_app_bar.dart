import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/app_user.dart';
import '../auth/auth_provider.dart';
import '../screens/about_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/courses_screen.dart';
import '../screens/digital_library_screen.dart';
import '../screens/my_orders_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/services_screen.dart';
import '../screens/store_screen.dart';
import '../theme/app_theme.dart';
import 'cart_badge_button.dart';

/// Shared header used by the role dashboards (and any other page that wants
/// the same navigation): logo, main menu, cart, account menu.
class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  static final Map<String, Widget Function()> _pages = {
    'About': () => const AboutScreen(),
    'Services': () => const ServicesScreen(),
    'Upskilling': () => const CoursesScreen(),
    'Store': () => const StoreScreen(),
    'Insights': () => const InsightsScreen(),
    'Contact': () => const ContactScreen(),
  };

  Future<void> _open(Widget page) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() {}); // refresh cart badge
  }

  String _roleLabel(String role) {
    switch (role) {
      case UserRole.individual:
        return 'Individual Learner';
      case UserRole.employer:
        return 'Employer';
      case UserRole.trainer:
        return 'Trainer';
      case UserRole.admin:
        return 'Administrator';
      default:
        return 'Guest';
    }
  }

  Widget _account(AuthProvider auth, bool desktop) {
    if (auth.isInitialising) return const SizedBox.shrink();

    if (!auth.isLoggedIn) {
      if (!desktop) {
        return IconButton(
          tooltip: 'Sign in',
          onPressed: () => _open(const LoginScreen()),
          icon: const Icon(Icons.login_rounded),
        );
      }
      return Row(
        children: [
          TextButton(
            onPressed: () => _open(const LoginScreen()),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.deepBlue,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
            ),
            child: const Text('Sign in',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => _open(const RegisterScreen()),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.deepBlue,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppTheme.deepBlue),
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text('Register',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      );
    }

    final user = auth.user!;
    final trimmed = user.name.trim();
    final first = trimmed.isEmpty ? 'Account' : trimmed.split(' ').first;

    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 48),
      onSelected: (v) async {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        if (v == 'dashboard') {
          navigator.popUntil((r) => r.isFirst);
        } else if (v == 'orders') {
          _open(const MyOrdersScreen());
        } else if (v == 'library') {
          _open(const DigitalLibraryScreen());
        } else if (v == 'logout') {
          navigator.popUntil((r) => r.isFirst);
          await auth.logout();
          messenger.showSnackBar(
            const SnackBar(content: Text('You have been signed out.')),
          );
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trimmed.isEmpty ? 'Account' : trimmed,
                style: const TextStyle(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(user.email,
                  style: const TextStyle(
                      color: AppTheme.greyText, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                _roleLabel(user.role),
                style: const TextStyle(
                  color: AppTheme.purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
            value: 'dashboard', child: Text('My Dashboard')),
        if (user.role == UserRole.individual || user.role == UserRole.employer) ...[
          const PopupMenuItem<String>(value: 'orders', child: Text('My Orders')),
          const PopupMenuItem<String>(
              value: 'library', child: Text('My Digital Products')),
        ],
        const PopupMenuItem<String>(value: 'logout', child: Text('Log out')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFE4E0E9)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.deepBlue,
              child: Text(
                first[0].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.softYellow,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            if (desktop) ...[
              const SizedBox(width: 8),
              Text(first,
                  style: const TextStyle(
                    color: AppTheme.darkText,
                    fontWeight: FontWeight.w700,
                  )),
            ],
            const Icon(Icons.arrow_drop_down, color: AppTheme.greyText),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final auth = context.watch<AuthProvider>();

    return AppBar(
      backgroundColor: const Color(0xFFF7F6F9),
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight + 8,
      titleSpacing: desktop ? 48 : 18,
      title: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.deepBlue,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: AppTheme.softYellow),
            ),
            const SizedBox(width: 12),
            const Text(
              'MT Alchemy',
              style: TextStyle(
                color: AppTheme.darkText,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (desktop)
          for (final entry in _pages.entries)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                onPressed: () => _open(entry.value()),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    color: AppTheme.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
        else
          PopupMenuButton<String>(
            tooltip: 'Menu',
            icon: const Icon(Icons.menu_rounded),
            onSelected: (t) => _open(_pages[t]!()),
            itemBuilder: (_) => [
              for (final t in _pages.keys)
                PopupMenuItem<String>(value: t, child: Text(t)),
            ],
          ),
        const SizedBox(width: 4),
        CartBadgeButton(onPressed: () => _open(const CartScreen())),
        const SizedBox(width: 4),
        _account(auth, desktop),
        SizedBox(width: desktop ? 48 : 12),
      ],
    );
  }
}
