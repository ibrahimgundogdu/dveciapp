import 'package:flutter/services.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'services/sharedpreferences.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const DveciApp());
  });
}

class DveciApp extends StatelessWidget {
  const DveciApp({super.key});

  Future<String?> getToken() async {
    var token = await ServiceSharedPreferences.getSharedString("token");
    return token;
  }

  void hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    hideSystemUI();
    return FutureBuilder<String?>(
        future: getToken(),
        builder: (context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Dveci Order',
              theme: ThemeData(
                primarySwatch: Colors.brown,
              ),
              home: const Home(),
            );
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Dveci Order',
              theme: ThemeData(
                primarySwatch: Colors.brown,
              ),
              home: const LoginPage(),
            );
          }
        });
  }
}
