import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'message_util.dart';
import 'book_logic.dart';
import 'store_screen.dart';
import 'book_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  final _formKey = GlobalKey<FormState>();

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
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
                child: Icon(Icons.menu_book, size: 45, color: Colors.white),
              ),
              SizedBox(height: 32),
              Text(
                "BookStore",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a2e),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Sign in to continue",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 48),

              // Email field
              _buildTextField(
                controller: _emailCtrl,
                hint: "Email",
                icon: Icons.email_outlined,
                validator: (text) {
                  if (text!.isEmpty) return "Email is required";
                  if (!EmailValidator.validate(text)) return "Invalid email";
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),

              // Password field
              _buildTextField(
                controller: _passCtrl,
                hint: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (text) {
                  if (text!.isEmpty) return "Password is required";
                  if (text.length < 6) return "Min 6 characters";
                  return null;
                },
              ),
              SizedBox(height: 32),
              _buildLoginButton(),
              SizedBox(height: 24),
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _hidePassword = true;

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _hidePassword : false,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[500],
                  ),
                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  final _service = BookService();

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _doLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFe94560),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _doLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      _service
          .login(_emailCtrl.text.trim(), _passCtrl.text)
          .then((user) async {
            if (!mounted) return;
            await context.read<BookLogic>().saveCacheUser(user);
            
            // Save to SharedPreferences for profile screen
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_name', user.user.name);
            await prefs.setString('user_email', user.user.email);
            
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(builder: (context) => StoreScreen()),
            );
          })
          .onError((e, s) {
            if (!mounted) return;
            setState(() { _isLoading = false; });
            showMessage(context, "Login failed. Check your credentials.");
          });
    }
  }

  Widget _buildRegisterLink() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => RegisterScreen()),
        );
      },
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(color: Colors.grey[600]),
          children: [
            TextSpan(
              text: "Sign up",
              style: TextStyle(color: Color(0xFFe94560), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
