import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'message_util.dart';
import 'book_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFe94560),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFe94560).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(Icons.person_add, size: 45, color: Colors.white),
              ),
              SizedBox(height: 32),
              Text("Create Account", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1a1a2e))),
              SizedBox(height: 8),
              Text("Sign up to get started", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              SizedBox(height: 40),

              _buildTextField(controller: _nameCtrl, hint: "Name", icon: Icons.person_outline,
                validator: (t) => t!.isEmpty ? "Name is required" : null),
              SizedBox(height: 16),
              _buildTextField(controller: _emailCtrl, hint: "Email", icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (t) {
                  if (t!.isEmpty) return "Email is required";
                  if (!EmailValidator.validate(t)) return "Invalid email";
                  return null;
                }),
              SizedBox(height: 16),
              _buildPasswordField(controller: _passCtrl, hint: "Password", hidePassword: _hidePassword,
                onToggle: () => setState(() => _hidePassword = !_hidePassword),
                validator: (t) {
                  if (t!.isEmpty) return "Password is required";
                  if (t.length < 6) return "Min 6 characters";
                  return null;
                }),
              SizedBox(height: 16),
              _buildPasswordField(controller: _confirmPassCtrl, hint: "Confirm Password", hidePassword: _hideConfirmPassword,
                onToggle: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword),
                validator: (t) {
                  if (t!.isEmpty) return "Please confirm";
                  if (t != _passCtrl.text) return "Passwords don't match";
                  return null;
                }),
              SizedBox(height: 32),
              _buildRegisterButton(),
              SizedBox(height: 24),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint, hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool hidePassword,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
      child: TextFormField(
        controller: controller,
        obscureText: hidePassword,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint, hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
          suffixIcon: IconButton(
            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500]),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  final _service = BookService();

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _doRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFe94560),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _doRegister() {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      _service
          .register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text)
          .then((user) {
            if (!mounted) return;
            showMessage(context, "Registration successful! Please login.");
            Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (c) => LoginScreen()));
          })
          .onError((e, s) {
            if (!mounted) return;
            setState(() { _isLoading = false; });
            showMessage(context, "Registration failed. Try different email.");
          });
    }
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (c) => LoginScreen())),
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: TextStyle(color: Colors.grey[600]),
          children: [TextSpan(text: "Login", style: TextStyle(color: Color(0xFFe94560), fontWeight: FontWeight.bold))],
        ),
      ),
    );
  }
}
