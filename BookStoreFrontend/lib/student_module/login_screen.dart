import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_screen.dart';
import 'message_util.dart';
import 'student_logic.dart';
import 'student_screen.dart';
import 'student_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  final _formKey = GlobalKey<FormState>();

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmailTextField(),
            _buildPasswordTextField(),
            _buildLoginButton(),
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  final _emailCtrl = TextEditingController();

  Widget _buildEmailTextField() {
    return TextFormField(
      controller: _emailCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        hintText: "Enter Email",
        border: OutlineInputBorder(),
      ),
      validator: (text) {
        if (text!.isEmpty) {
          return "Email is required";
        }
        if (EmailValidator.validate(text) == false) {
          return "Email format is not correct";
        }
        return null;
      },
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    );
  }

  final _passCtrl = TextEditingController();
  bool _hidePassword = true;

  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.key),
        hintText: "Enter Password",
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _hidePassword = !_hidePassword;
            });
          },
          icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      validator: (text) {
        if (text!.isEmpty) {
          return "Password is required";
        }
        if (text.length < 6) {
          return "Password needs at least 6 characters";
        }
        return null;
      },
      obscureText: _hidePassword,
      textInputAction: TextInputAction.done,
    );
  }

  final _service = StudentService();

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _service
              .login(_emailCtrl.text.trim(), _passCtrl.text)
              .then((user) async {
                await context.read<StudentLogic>().saveCacheUser(user);
                Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(builder: (context) => StudentScreen()),
                );
              })
              .onError((e, s) {
                showMessage(context, e.toString());
              });
        }
      },
      child: Text("LOGIN"),
    );
  }

  Widget _buildRegisterLink() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => RegisterScreen()),
        );
      },
      child: Text("No account yet? Register a new account"),
    );
  }
}
