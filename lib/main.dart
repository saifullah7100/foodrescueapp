import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foods_rescue/Utils/customtheme.dart';
import 'package:foods_rescue/Utils/sharedprefs.dart';
import 'package:foods_rescue/authentication/login_screen_and_sign_up.dart';
import 'package:foods_rescue/firebase_options.dart';
import 'package:foods_rescue/splash/splash_screen.dart';
import 'package:foods_rescue/ui/chat_screen.dart';
import 'package:provider/provider.dart';

FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AndroidInitializationSettings androidSettings = const AndroidInitializationSettings(
      '@mipmap/ic_launcher'); // ensure this is the correct resource
  InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await notificationsPlugin.initialize(initSettings);

  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
final ThemePreference _themePreference = ThemePreference();
    late bool _isDarkTheme =false ;
     @override
     void initState() {
       super.initState();
       _getTheme();
     }

     _getTheme() async {
       _isDarkTheme = await _themePreference.getTheme();
       setState(() {});
     }


  void toggleCallback(){
   setState(() {
     _isDarkTheme =!_isDarkTheme;
   });
   _themePreference.setTheme(_isDarkTheme);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider1>(create: (_) => AuthProvider1()),
        ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Food Rescue',
        theme: Customtheme.lighttheme,
        darkTheme: Customtheme.darktheme,
        themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light ,
        home: SplashScreen(login: AuthProvider1().isLoggedIn, isDarkMode: _isDarkTheme, toggleCallback: toggleCallback),
      ),
    );
  }
}
