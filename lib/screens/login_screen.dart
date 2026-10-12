
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
const LoginScreen({super.key});

@override
State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();

bool _hidePassword = true;

@override
void dispose() {
_emailController.dispose();
_passwordController.dispose();
super.dispose();
}

void _signIn() {
FocusScope.of(context).unfocus();

if (_formKey.currentState!.validate()) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Demo sign in successful! No account was verified.',
),
),
);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: AppTheme.background,
appBar: AppBar(
title: const Text('Sign In'),
backgroundColor: AppTheme.background,
foregroundColor: AppTheme.deepBlue,
),
body: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24),
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 480),
child: Container(
padding: const EdgeInsets.all(28),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(24),
border: Border.all(
color: const Color(0xFFE4E0E9),
),
),
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
const Icon(
Icons.auto_awesome_rounded,
color: AppTheme.purple,
size: 42,
),
const SizedBox(height: 16),
const Text(
'Welcome Back',
textAlign: TextAlign.center,
style: TextStyle(
color: AppTheme.deepBlue,
fontSize: 28,
fontWeight: FontWeight.w800,
),
),
const SizedBox(height: 8),
const Text(
'Sign in to continue your learning journey.',
textAlign: TextAlign.center,
style: TextStyle(
color: AppTheme.greyText,
),
),
const SizedBox(height: 28),

const Text(
'Email Address',
style: TextStyle(
fontWeight: FontWeight.w600,
),
),
const SizedBox(height: 8),
TextFormField(
controller: _emailController,
keyboardType: TextInputType.emailAddress,
decoration: const InputDecoration(
hintText: 'Enter your email',
prefixIcon: Icon(Icons.email_outlined),
border: OutlineInputBorder(),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'Please enter your email address';
}
if (!RegExp(
r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
).hasMatch(value.trim())) {
return 'Please enter a valid email address';
}
return null;
},
),
const SizedBox(height: 20),

const Text(
'Password',
style: TextStyle(
fontWeight: FontWeight.w600,
),
),
const SizedBox(height: 8),
TextFormField(
controller: _passwordController,
obscureText: _hidePassword,
decoration: InputDecoration(
hintText: 'Enter your password',
prefixIcon: const Icon(Icons.lock_outline),
border: const OutlineInputBorder(),
suffixIcon: IconButton(
onPressed: () {
setState(() {
_hidePassword = !_hidePassword;
});
},
icon: Icon(
_hidePassword
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
),
),
),
validator: (value) {
if (value == null || value.isEmpty) {
return 'Please enter your password';
}
return null;
},
),
const SizedBox(height: 12),

Align(
alignment: Alignment.centerRight,
child: TextButton(
onPressed: () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Password recovery is a prototype placeholder.',
),
),
);
},
child: const Text('Forgot password?'),
),
),
const SizedBox(height: 12),

SizedBox(
height: 50,
child: ElevatedButton(
onPressed: _signIn,
style: ElevatedButton.styleFrom(
backgroundColor: AppTheme.deepBlue,
foregroundColor: Colors.white,
),
child: const Text('Sign In'),
),
),
const SizedBox(height: 18),

Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Flexible(
child: Text("Don't have an account? "),
),
TextButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const RegisterScreen(),
),
);
},
child: const Text('Register'),
),
],
),
],
),
),
),
),
),
),
);
}
}