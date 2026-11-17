import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../theme/app_theme.dart';

class ContactScreen extends StatefulWidget {
  /// Optional pre-filled enquiry type (must be one of the dropdown options).
  final String? initialType;
  final String? service; // e.g. "Leadership & Communication"
  final String? initialMessage;
  final String source; // contact | services | organizations | programmes | coaching | about

  const ContactScreen({
    super.key,
    this.initialType,
    this.service,
    this.initialMessage,
    this.source = 'contact',
  });
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  static const _enquiryTypes = [
    'Individual Coaching',
    'Corporate Training',
    'Leadership Development',
    'Team Development',
    'Workshop',
    'Products',
    'Partnership',
    'Other',
  ];

  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _company = TextEditingController();
  final _message = TextEditingController();

  String? _enquiryType;
  bool _sending = false;
  int _formVersion = 0; // changes after a successful send to reset the dropdown

  @override
  void initState() {
    super.initState();
    // Pre-fill from the logged-in account, if any.
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _name.text = user.name;
      _email.text = user.email;
      _phone.text = (user.extra['phone'] ?? '') as String;
      _company.text = (user.extra['organizationName'] ?? '') as String;
    }
    if (widget.initialType != null &&
        _enquiryTypes.contains(widget.initialType)) {
      _enquiryType = widget.initialType;
    }
    if (widget.initialMessage != null) {
      _message.text = widget.initialMessage!;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _company.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LET’S CONNECT',
                        style: TextStyle(
                          color: AppTheme.softYellow,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.4,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Let's build a thriving workplace together.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 29,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Tell us how we can support you or your organisation.',
                        style: TextStyle(color: Colors.white70, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _key,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 560;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _pair(
                            wide,
                            _field(_name, 'Full name', Icons.person_outline),
                            _field(_email, 'Email address',
                                Icons.email_outlined,
                                email: true),
                          ),
                          _pair(
                            wide,
                            _field(_phone, 'Phone number',
                                Icons.phone_outlined,
                                phone: true),
                            _field(_company, 'Company / Organisation',
                                Icons.business_outlined,
                                optional: true),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: DropdownButtonFormField<String>(
                              key: ValueKey('enquiry-$_formVersion'),
                              initialValue: _enquiryType,
                              isExpanded: true,
                              decoration: _decoration(
                                  'Enquiry type', Icons.subject_outlined),
                              items: [
                                for (final t in _enquiryTypes)
                                  DropdownMenuItem(value: t, child: Text(t)),
                              ],
                              onChanged: (v) =>
                                  setState(() => _enquiryType = v),
                              validator: (v) => v == null
                                  ? 'Please choose an enquiry type'
                                  : null,
                            ),
                          ),
                          _field(_message, 'Message',
                              Icons.chat_bubble_outline,
                              lines: 4),
                          const SizedBox(height: 6),
                          ElevatedButton.icon(
                            onPressed: _sending ? null : _submit,
                            icon: _sending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send_outlined),
                            label: Text(_sending ? 'Sending…' : 'Send Message'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.deepBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 13),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pair(bool wide, Widget a, Widget b) {
    if (!wide) return Column(children: [a, b]);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 16),
        Expanded(child: b),
      ],
    );
  }

  InputDecoration _decoration(String label, IconData icon, {int lines = 1}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: lines == 1 ? Icon(icon) : null,
      alignLabelWithHint: lines > 1,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool email = false,
    bool phone = false,
    bool optional = false,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        keyboardType: email
            ? TextInputType.emailAddress
            : phone
                ? TextInputType.phone
                : TextInputType.text,
        decoration: _decoration(optional ? '$label (optional)' : label, icon,
            lines: lines),
        validator: (value) {
          final v = value?.trim() ?? '';
          if (optional && v.isEmpty) return null;
          if (v.isEmpty) return 'Please enter $label';
          if (email && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
            return 'Enter a valid email address';
          }
          if (phone &&
              !RegExp(r'^\d{8,15}$')
                  .hasMatch(v.replaceAll(RegExp(r'[\s\-+()]'), ''))) {
            return 'Enter a valid phone number';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _sending = true);

    final uid = context.read<AuthProvider>().user?.uid;
    final messenger = ScaffoldMessenger.of(context);

    try {
      await FirebaseFirestore.instance.collection('enquiries').add({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'organisation': _company.text.trim(),
        'enquiryType': _enquiryType,
        'message': _message.text.trim(),
        'service': widget.service ?? '',
        'source': widget.source,
        'notes': '',
        'status': 'new',
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() {
        _sending = false;
        _enquiryType = null;
        _formVersion++;
        _message.clear();
      });
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thank you!'),
          content: const Text(
              'Your enquiry has been sent. The MT Alchemy team will get back to you soon.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Enquiry failed: $e');
      if (!mounted) return;
      setState(() => _sending = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not send your message. Please try again.'),
        ),
      );
    }
  }
}
