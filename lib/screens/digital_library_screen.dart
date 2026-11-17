import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../learning/course_models.dart';
import '../store/product_pdf.dart';
import '../store/store_service.dart';
import '../theme/app_theme.dart';
import '../widgets/main_app_bar.dart';
import 'store_screen.dart';

/// My Digital Products (brief Page 24). A file is only released after the
/// app re-checks, on the server, that this user bought the product.
class DigitalLibraryScreen extends StatefulWidget {
  const DigitalLibraryScreen({super.key});

  @override
  State<DigitalLibraryScreen> createState() => _DigitalLibraryScreenState();
}

class _DigitalLibraryScreenState extends State<DigitalLibraryScreen> {
  String? _busyId;

  Future<void> _download(DigitalEntitlement e) async {
    final auth = context.read<AuthProvider>();
    final uid = auth.user?.uid;
    final messenger = ScaffoldMessenger.of(context);
    if (uid == null) return;

    setState(() => _busyId = e.id);
    try {
      final owns = await StoreService.instance.hasPurchased(uid, e.productId);
      if (!owns) {
        messenger.showSnackBar(const SnackBar(
            content: Text('We could not verify your purchase of this product.')));
      } else {
        final bytes = await buildProductPdf(
          productName: e.productName,
          licensedTo: auth.user?.name ?? 'Customer',
          orderNumber: e.orderNumber,
        );
        await Printing.sharePdf(
          bytes: bytes,
          filename: e.fileName.isEmpty ? '${e.productName}.pdf' : e.fileName,
        );
      }
    } catch (err) {
      debugPrint('Download failed: $err');
      messenger.showSnackBar(
          const SnackBar(content: Text('Download failed. Please try again.')));
    }
    if (mounted) setState(() => _busyId = null);
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const MainAppBar(),
      body: uid == null
          ? const Center(child: Text('Please sign in to open your library.'))
          : StreamBuilder<List<DigitalEntitlement>>(
              stream: StoreService.instance.libraryFor(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snap.data ?? const <DigitalEntitlement>[];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('My Digital Products',
                              style: TextStyle(
                                  color: AppTheme.deepBlue,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          const Text(
                              'Your purchased downloads. Only you can access these files.',
                              style: TextStyle(color: AppTheme.greyText)),
                          const SizedBox(height: 20),
                          if (snap.hasError)
                            const Text(
                                'Your library could not be loaded. Check that the Firestore rules are published.')
                          else if (items.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: const Color(0xFFE4E0E9)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.cloud_download_outlined,
                                      size: 40, color: AppTheme.purple),
                                  const SizedBox(height: 10),
                                  const Text(
                                      'No digital products yet. Buy one in the store and it will appear here.',
                                      textAlign: TextAlign.center),
                                  const SizedBox(height: 14),
                                  OutlinedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const StoreScreen()),
                                    ),
                                    child: const Text('Visit Store'),
                                  ),
                                ],
                              ),
                            )
                          else
                            for (final e in items) _card(e),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _card(DigitalEntitlement e) {
    final busy = _busyId == e.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E0E9)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.purple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.picture_as_pdf_outlined,
                color: AppTheme.purple, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.productName,
                    style: const TextStyle(
                        color: AppTheme.deepBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Purchased: ${formatDate(e.purchasedAt)} · Order #${e.orderNumber}',
                    style: const TextStyle(
                        color: AppTheme.greyText, fontSize: 12)),
                if (e.accessInstructions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(e.accessInstructions,
                      style: const TextStyle(
                          color: AppTheme.greyText, fontSize: 12, height: 1.4)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: busy ? null : () => _download(e),
            icon: busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download_rounded, size: 18),
            label: Text(busy ? 'Checking…' : 'Download'),
          ),
        ],
      ),
    );
  }
}
