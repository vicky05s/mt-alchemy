import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _subject.dispose(); _message.dispose();
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
                  decoration: BoxDecoration(color: AppTheme.deepBlue, borderRadius: BorderRadius.circular(24)),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('LET’S CONNECT', style: TextStyle(color: AppTheme.softYellow, fontWeight: FontWeight.bold, letterSpacing: 1.4)),
                    SizedBox(height: 12),
                    Text('How can we support your growth?', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Send a message using the form below.', style: TextStyle(color: Colors.white70, height: 1.5)),
                  ]),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _key,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _field(_name, 'Full name', Icons.person_outline),
                    _field(_email, 'Email address', Icons.email_outlined, email: true),
                    _field(_subject, 'Subject', Icons.subject_outlined),
                    _field(_message, 'Message', Icons.chat_bubble_outline, lines: 4),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('Send Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepBlue, foregroundColor: Colors.white,
                          minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {bool email = false, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller, maxLines: lines,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(labelText: label, prefixIcon: lines == 1 ? Icon(icon) : null, alignLabelWithHint: lines > 1, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Please enter $label';
          if (email && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) return 'Enter a valid email address';
          return null;
        },
      ),
    );
  }

  void _submit() {
    if (!_key.currentState!.validate()) return;
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: const Text('Message ready'),
      content: const Text('This prototype validates your message locally. No message has been sent to a server.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }
}
