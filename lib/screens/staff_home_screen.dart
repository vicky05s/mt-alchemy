import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/app_user.dart';
import '../auth/auth_provider.dart';
import '../auth/role_gate.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/stat_card.dart';
import 'admin_enquiries_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_screen.dart';

/// Home for Trainer and Administrator accounts.
class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.role == UserRole.admin;
    final name = (user?.name ?? '').trim();
    final first = name.isEmpty ? 'there' : name.split(' ').first;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F9),
      appBar: const MainAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.deepBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAdmin ? 'ADMINISTRATOR' : 'TRAINER',
                        style: const TextStyle(
                          color: AppTheme.softYellow,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Welcome, $first',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAdmin
                            ? 'Manage users, courses, products and orders.'
                            : 'Manage your courses, materials and learners.',
                        style: const TextStyle(
                            color: Colors.white70, height: 1.5),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RoleGate(
                              allowed: [UserRole.admin, UserRole.trainer],
                              child: AdminScreen(),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        label: Text(
                            isAdmin ? 'Open Admin Portal' : 'Open Trainer Portal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.softYellow,
                          foregroundColor: AppTheme.deepBlue,
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RoleGate(
                                allowed: [UserRole.admin],
                                child: AdminOrdersScreen(),
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.local_shipping_outlined),
                          label: const Text('Manage Orders'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RoleGate(
                                allowed: [UserRole.admin, UserRole.trainer],
                                child: AdminEnquiriesScreen(),
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.mark_email_unread_outlined),
                          label: const Text('Manage Enquiries'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const DashCard(
                  title: 'What is coming here',
                  child: Text(
                    'Live counts of users, enrolments, orders and enquiries will '
                    'appear on this page once the course and order data is connected.',
                    style: TextStyle(color: AppTheme.greyText, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
