import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'message_util.dart';
import 'student_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
            _buildNameTextField(),
            _buildEmailTextField(),
            _buildPasswordTextField(),
            _buildPasswordConfirmationTextField(),
            _buildRegisterButton(),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  final _nameCtrl = TextEditingController();

  Widget _buildNameTextField() {
    return TextFormField(
      controller: _nameCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        hintText: "Enter Name",
        border: OutlineInputBorder(),
      ),
      validator: (text) {
        if (text!.isEmpty) {
          return "Name is required";
        }
        return null;
      },
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
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
      textInputAction: TextInputAction.next,
    );
  }

  final _passConfirmationCtrl = TextEditingController();

  Widget _buildPasswordConfirmationTextField() {
    return TextFormField(
      controller: _passConfirmationCtrl,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.key),
        hintText: "Enter Password Confirmation",
        border: OutlineInputBorder(),
      ),
      validator: (text) {
        if (text!.isEmpty) {
          return "Password is required";
        }
        if (text.length < 6) {
          return "Password needs at least 6 characters";
        }

        if (text != _passCtrl.text) {
          return "Password does not match to Password Confirmation";
        }

        return null;
      },
      obscureText: _hidePassword,
      textInputAction: TextInputAction.done,
    );
  }

  StudentService _service = StudentService();

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _service
              .register(
                _nameCtrl.text.trim(),
                _emailCtrl.text.trim(),
                _passCtrl.text,
              )
              .then((user) {
                Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(builder: (context) => LoginScreen()),
                );
              })
              .onError((e, s) {
                showMessage(context, e.toString());
              });
        }
      },
      child: Text("REGISTER"),
    );
  }

   Widget _buildLoginLink() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => LoginScreen()),
        );
      },
      child: Text("Already has account? Login"),
    );
  }
}
