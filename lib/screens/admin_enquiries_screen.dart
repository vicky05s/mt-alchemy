import 'package:flutter/material.dart';

import '../enquiries/enquiry_service.dart';
import '../learning/course_models.dart';
import '../store/store_ui.dart';
import '../theme/app_theme.dart';

/// Staff inbox for Journey E. Move an enquiry through
/// New -> Contacted -> Consultation -> Customised proposal -> Purchased.
class AdminEnquiriesScreen extends StatefulWidget {
  const AdminEnquiriesScreen({super.key});

  @override
  State<AdminEnquiriesScreen> createState() => _AdminEnquiriesScreenState();
}

class _AdminEnquiriesScreenState extends State<AdminEnquiriesScreen> {
  late final Stream<List<EnquiryRecord>> _stream;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _stream = EnquiryService.instance.all();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Enquiries')),
      body: StreamBuilder<List<EnquiryRecord>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(
                child: Text('Enquiries could not be loaded. Are the rules published?'));
          }
          final all = snap.data ?? const <EnquiryRecord>[];
          final shown =
              _filter == 'all' ? all : all.where((e) => e.status == _filter).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text('All (${all.length})'),
                            selected: _filter == 'all',
                            onSelected: (_) => setState(() => _filter = 'all'),
                          ),
                          for (final s in enquiryStatuses)
                            ChoiceChip(
                              label: Text(
                                  '${s.$2} (${all.where((e) => e.status == s.$1).length})'),
                              selected: _filter == s.$1,
                              onSelected: (_) => setState(() => _filter = s.$1),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (shown.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(30),
                          child: Center(child: Text('No enquiries here.')),
                        )
                      else
                        for (final e in shown) _EnquiryCard(key: ValueKey(e.id), enquiry: e),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EnquiryCard extends StatefulWidget {
  final EnquiryRecord enquiry;
  const _EnquiryCard({super.key, required this.enquiry});

  @override
  State<_EnquiryCard> createState() => _EnquiryCardState();
}

class _EnquiryCardState extends State<_EnquiryCard> {
  late String _status = widget.enquiry.status;
  late final TextEditingController _notes =
      TextEditingController(text: widget.enquiry.notes);
  bool _saving = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await EnquiryService.instance
          .update(widget.enquiry.id, status: _status, notes: _notes.text.trim());
      messenger.showSnackBar(const SnackBar(content: Text('Enquiry updated.')));
    } catch (e) {
      debugPrint('Enquiry update failed: $e');
      messenger.showSnackBar(
          const SnackBar(content: Text('Could not update the enquiry.')));
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.enquiry;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E0E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  e.organisation.isEmpty ? e.name : '${e.organisation} · ${e.name}',
                  style: const TextStyle(
                      color: AppTheme.deepBlue,
                      fontSize: 17,
                      fontWeight: FontWeight.w800),
                ),
              ),
              StatusChip(enquiryStatusLabel(e.status)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${e.email} · ${e.phone} · ${formatDate(e.createdAt)}',
            style: const TextStyle(color: AppTheme.greyText, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Chip(
                  label: Text(e.enquiryType, style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact),
              if (e.service.isNotEmpty)
                Chip(
                    label: Text(e.service, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact),
              if (e.source.isNotEmpty)
                Chip(
                    label: Text('from ${e.source}',
                        style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact),
            ],
          ),
          const SizedBox(height: 10),
          Text(e.message, style: const TextStyle(height: 1.5)),
          const Divider(height: 28),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                  key: ValueKey('${e.id}-$_status'),
                  initialValue: _status,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Status', border: OutlineInputBorder()),
                  items: [
                    for (final s in enquiryStatuses)
                      DropdownMenuItem(value: s.$1, child: Text(s.$2)),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
              ),
              SizedBox(
                width: 380,
                child: TextField(
                  controller: _notes,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Internal notes (consultation date, proposal...)',
                      border: OutlineInputBorder()),
                ),
              ),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving…' : 'Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
