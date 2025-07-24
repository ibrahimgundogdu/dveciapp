import 'package:flutter/services.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'services/sharedpreferences.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.white,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const DveciApp());
}

class DveciApp extends StatelessWidget {
  const DveciApp({super.key});

  Future<String?> getToken() async {
    var token = await ServiceSharedPreferences.getSharedString("token");
    return token;
  }

  // void hideSystemUI() {
  //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,overlays: []);
  // }

  @override
  Widget build(BuildContext context) {
    //hideSystemUI();
    return FutureBuilder<String?>(
        future: getToken(),
        builder: (context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          else  {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Dveci Order',
              theme: ThemeData(
                  primarySwatch: Colors.blue,
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
                  useMaterial3: true,
                  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                    backgroundColor: Colors.transparent,
                  )

              ),
              home: snapshot.hasData ? const Home() :  const LoginPage(),
            );
          }


        });
  }
}
