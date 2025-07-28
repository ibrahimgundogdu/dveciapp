import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/userauthentication.dart';
import 'home.dart';
import '../database/db_helper.dart';
import '../repositories/loginrepository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LoginRepository _loginRepository = LoginRepository();
  final DbHelper _dbHelper = DbHelper.instance;

  String? _statusMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _statusMessage = null;
      });

      try {
        final result = await _loginRepository.getToken(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (result?.isSuccess == true && result?.token != null) {
          await _addUserAuthentication(result!.token!);
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Home()),
            );
          }
        } else {
          setState(() {
            _statusMessage = result?.message ??
                'The sign in is unsuccessful. Please check your information.';
          });
        }
      } catch (e) {
        setState(() {
          _statusMessage = 'An error occurred';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _addUserAuthentication(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);

    var employee = await _loginRepository.getEmployee(token);
    if (employee != null && employee.employee?.id != null) {
      UserAuthentication auth = UserAuthentication(
        0,
        employee.employee!.id,
        employee.employee!.employeeName,
        DateTime.now(),
        DateTime.now().add(const Duration(days: 10000)),
        token,
      );
      await _dbHelper.addUserAuthentication(auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildLoginPageContent(screenHeight, screenWidth),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginPageContent(double screenHeight, double screenWidth) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final Color hintColor = Colors.grey.shade600;
    final Color errorColor = Theme.of(context).colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.shade100,
            Colors.pink.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    bottom: screenHeight * 0.05, top: screenHeight * 0.01),
                child: Column(
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.pink.shade200,
                          width: 5.0,
                        ),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                  ],
                ),
              ),
              Card(
                elevation: 0.4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Sign In',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                            color: Colors.brown.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        if (_statusMessage != null &&
                            _statusMessage!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              _statusMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: errorColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        _buildEmailTextField(hintColor, textColor),
                        const SizedBox(height: 16.0),
                        _buildPasswordTextField(hintColor, textColor),
                        const SizedBox(height: 25.0),
                        _buildLoginButton(primaryColor),
                        // İsteğe bağlı: Şifremi unuttum vs.
                        // _buildForgotPasswordButton(context),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              const Center(
                child: Padding(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: Text('V 1.0')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField(Color hintColor, Color textColor) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: "E-mail address",
        hintStyle: TextStyle(color: hintColor.withValues(alpha: 0.7)),
        prefixIcon:
            Icon(Icons.alternate_email_rounded, color: hintColor, size: 18),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'E-mail cannot be empty!';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Enter a valid e-mail address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordTextField(Color hintColor, Color textColor) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: TextStyle(color: hintColor.withValues(alpha: 0.7)),
        prefixIcon:
            Icon(Icons.lock_outline_rounded, color: hintColor, size: 18),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: hintColor,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'The password cannot be empty';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(Color primaryColor) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF08080),
          padding: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 1,
          shadowColor: primaryColor.withValues(alpha: 0.1),
        ),
        onPressed: _isLoading ? null : _login,
        child: Text(
          'LOGIN',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

// Örnek: Şifremi Unuttum butonu (isteğe bağlı)
/*
  Widget _buildForgotPasswordButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: TextButton(
        onPressed: () {
          // Şifremi unuttum sayfasına yönlendirme veya dialog gösterme
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Şifremi Unuttum özelliği henüz aktif değil.')),
          );
        },
        child: Text(
          'Şifrenizi mi unuttunuz?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  */
}
