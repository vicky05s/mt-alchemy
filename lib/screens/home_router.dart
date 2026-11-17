import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/app_user.dart';
import '../auth/auth_provider.dart';
import '../learning/certificate_utils.dart';
import 'employer_home_screen.dart';
import 'home_screen.dart';
import 'learner_home_screen.dart';
import 'staff_home_screen.dart';
import 'verify_certificate_screen.dart';

/// The app's start page. Shows a different home for each kind of visitor:
///   guest      -> public marketing home
///   individual -> learner dashboard
///   employer   -> employer dashboard
///   trainer / admin -> staff home
class HomeRouter extends StatelessWidget {
  const HomeRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Someone scanned a certificate QR code: show the public verification page.
    final verifyId = verifyIdFromUrl();
    if (verifyId != null) return VerifyCertificateScreen(certificateId: verifyId);

    if (auth.isInitialising) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    switch (auth.role) {
      case UserRole.individual:
        return const LearnerHomeScreen();
      case UserRole.employer:
        return const EmployerHomeScreen();
      case UserRole.admin:
      case UserRole.trainer:
        return const StaffHomeScreen();
      default:
        return const HomeScreen();
    }
  }
}
