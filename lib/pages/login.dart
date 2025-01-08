import '../models/userauthentication.dart';
import 'home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../database/db_helper.dart';
import '../repositories/loginrepository.dart';
import '../services/sharedpreferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  LoginRepository loginRepository = LoginRepository();
  //ServiceSharedPreferences sharedPreferences = ServiceSharedPreferences();
  String? _statusMessage = 'Please sign in';
  final DbHelper _dbHelper = DbHelper.instance;

  @override
  Future<void> dispose() async {
    userName.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFEAEFFF),
                Color(0xFFEAEFFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.only(top: 50.0),
          child: Column(
            children: [
              const Center(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Dveci',
                      style: TextStyle(fontSize: 20, color: Color(0xffa6b0d4)),
                    )),
              ),
              Container(
                decoration: const BoxDecoration(
                    color: Color(0xFFffffff),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30.0),
                        topLeft: Radius.circular(30.0))),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Stack(
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Stack(children: [
                                          Positioned(
                                              width: 80.0,
                                              height: 80.0,
                                              top: 0,
                                              child: Icon(
                                                Icons.account_circle,
                                                color: Color(0xFFB79C91),
                                                size: 100,
                                              )),
                                        ]),
                                      ),
                                      SizedBox(
                                        width: 80,
                                        height: 30,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Welcome',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.openSans(
                                      color: const Color(0xFF172B4D),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    _statusMessage ?? "Please sign in",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.openSans(
                                      color: const Color(0xFF7A869A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            height: 40.0,
                          ),
                          Text(
                            'E-Mail',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.openSans(
                              color: const Color(0xFFC1C7D0),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          TextFormField(
                            controller: userName,
                            keyboardType: TextInputType.name,
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF4F5F7),
                              hintText: "E-Mail",
                              prefixIcon: Icon(
                                Icons.alternate_email,
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return 'E-Mail required';
                                } else if (!value.contains('@')) {
                                  return 'Complete Real E-Mail';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'Password',
                            style: GoogleFonts.openSans(
                              color: const Color(0xFFC1C7D0),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          TextFormField(
                            obscureText: true,
                            controller: password,
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF4F5F7),
                              hintText: "Password",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return 'Password is required';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20))
                                  .copyWith(
                                      elevation:
                                          ButtonStyleButton.allOrNull(0.0)),
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    });

                                final formIsValid =
                                    formKey.currentState?.validate();
                                if (formIsValid == true) {
                                  var _result = await loginRepository.GetToken(
                                      userName.text, password.text);
                                  if (_result?.isSuccess == true) {
                                    await addUserAuthentication(_result?.token);

                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return const Home();
                                    }));
                                  } else {
                                    setState(() {
                                      _statusMessage = _result?.message;
                                    });
                                  }
                                }
                              },
                              child: const Text('Sign In'),
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            width: double.infinity,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            width: double.infinity,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addUserAuthentication(String? token) async {
    if (token != null && token.isNotEmpty) {
      ServiceSharedPreferences.setSharedString("token", token);
      LoginRepository loginRepository = LoginRepository();

      var _employee = await loginRepository.GetEmployee(token);
      if (_employee != null) {
        UserAuthentication auth = UserAuthentication(
            0,
            _employee?.employee?.id,
            _employee?.employee?.employeeName,
            DateTime.now(),
            DateTime.now().add(const Duration(days: 10000)),
            token);
        _dbHelper.addUserAuthentication(auth);
      }
    }
  }
}

class CheckboxItem extends StatefulWidget {
  const CheckboxItem({Key? key}) : super(key: key);

  @override
  State<CheckboxItem> createState() => _CheckboxItemState();
}

class _CheckboxItemState extends State<CheckboxItem> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }
}
