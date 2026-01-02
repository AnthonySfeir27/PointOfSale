import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_page.dart';
import 'services/user_service.dart';
import 'screens/sales_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String apiBaseUrl = 'http://localhost:5000/users';

  @override
  Widget build(BuildContext context) {
    final userService = UserService(baseUrl: apiBaseUrl);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supermarket POS',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(userService: userService),
        '/signup': (_) => SignupScreen(userService: userService),
        '/home': (context) {
          final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'cashier';
          return HomePage(role: role);
        },
        '/sales': (context) {
          final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'cashier';
          return SalesPage(role: role);
        },
      },
    );
  }
}