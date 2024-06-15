import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:login_app/home_page.dart';

class LoginScreen extends StatelessWidget {
  final String correctMobile = '9033006262';
  final String correctPassword = 'eVital@12';

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authenticateUser(LoginData data) async {
    if (data.name != correctMobile) {
      return 'Mobile number is incorrect';
    }
    if (data.password != correctPassword) {
      return 'Password is incorrect';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Login',
      onLogin: _authenticateUser,
      onRecoverPassword: (String name) => Future(() => null),
      messages: LoginMessages(
        userHint: 'Mobile',
        passwordHint: 'Password',
        confirmPasswordError: 'Passwords do not match',
        recoverPasswordDescription: 'Recover your password here',
      ),
      theme: LoginTheme(
        primaryColor: const Color.fromARGB(255, 17, 97, 216),
        accentColor: Colors.white,
        errorColor: Colors.red,
      ),
      userValidator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your mobile number';
        }
        return null;
      },
      passwordValidator: (value) {
        if (value!.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
      onSubmitAnimationCompleted: (){
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
    );
  }
}
