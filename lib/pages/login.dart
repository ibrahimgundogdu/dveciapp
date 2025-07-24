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
                'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.';
          });
        }
      } catch (e) {
        setState(() {
          _statusMessage = 'Bir hata oluştu: ${e.toString()}';
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
    // Ana tema renklerini veya markanıza özel renkleri kullanabilirsiniz.
    // Bu örnekte varsayılan tema renkleri kullanılıyor.
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    final Color textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    final Color hintColor = Colors.grey.shade600;
    final Color errorColor = Theme.of(context).colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.9),
            secondaryColor.withValues(alpha: 0.8),
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
                    bottom: screenHeight * 0.04, top: screenHeight * 0.06),
                child: Column(
                  children: [
                    Icon(Icons.store_mall_directory_outlined,
                        // Uygulamanızı temsil eden bir ikon
                        size: screenHeight * 0.1,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 15.0,
                            color: Colors.black.withValues(alpha: 0.4),
                            offset: const Offset(3.0, 3.0),
                          ),
                        ]),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Dveci',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                          // Daha modern ve yumuşak bir font
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(2.0, 2.0),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
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
                          'Giriş Yap',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.openSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: textColor,
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
              SizedBox(height: screenHeight * 0.05), // Altta biraz boşluk
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
        hintText: "E-posta Adresiniz",
        hintStyle: TextStyle(color: hintColor.withValues(alpha: 0.7)),
        prefixIcon: Icon(Icons.alternate_email_rounded, color: hintColor),
        filled: true,
        fillColor: Colors.grey.shade100.withValues(alpha: 0.8),
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
          return 'E-posta boş bırakılamaz';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Geçerli bir e-posta adresi giriniz';
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
        hintText: "Şifreniz",
        hintStyle: TextStyle(color: hintColor.withValues(alpha: 0.7)),
        prefixIcon: Icon(Icons.lock_outline_rounded, color: hintColor),
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
        fillColor: Colors.grey.shade100.withValues(alpha: 0.8),
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
          return 'Şifre boş bırakılamaz';
        }
        // İsteğe bağlı: Minimum şifre uzunluğu kontrolü
        // if (value.length < 6) {
        //   return 'Şifre en az 6 karakter olmalıdır';
        // }
        return null;
      },
    );
  }

  Widget _buildLoginButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 5,
          shadowColor: primaryColor.withValues(alpha: 0.4),
        ),
        onPressed: _isLoading ? null : _login,
        // Yükleme sırasında butonu devre dışı bırak
        child: Text(
          'GİRİŞ YAP',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 16,
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
