import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_page.dart';
import 'services/user_service.dart';
import 'services/product_service.dart';
import 'services/sale_service.dart';
import 'screens/sales_page.dart';
import 'screens/dashboard_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_form_screen.dart';
import 'screens/user_list_screen.dart';
import 'models/product_model.dart';
import 'models/user_model.dart';
import 'services/analytics_service.dart';
import 'constants.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String apiBaseUrl = '${AppConstants.baseUrl}/users';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userService = UserService(baseUrl: apiBaseUrl);
    final productService = ProductService(
      baseUrl: '${AppConstants.baseUrl}/products',
    );
    final saleService = SaleService(baseUrl: '${AppConstants.baseUrl}/sales');
    final analyticsService = AnalyticsService(
      baseUrl: '${AppConstants.baseUrl}/api/analytics',
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supermarket POS',
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(userService: userService),
        '/signup': (_) => SignupScreen(userService: userService),
        '/users': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final user = args is User ? args : null;
          return UserListScreen(userService: userService, currentUser: user);
        },
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final user = args is User
              ? args
              : User(username: 'Admin', role: 'admin');
          return DashboardScreen(
            analyticsService: analyticsService,
            user: user,
          );
        },
        '/products': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final user = args is User ? args : null;
          return ProductListScreen(productService: productService, user: user);
        },
        '/edit-product': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          Product? product;
          User? user;
          if (args is Map) {
            product = args['product'] as Product?;
            user = args['user'] as User?;
          } else if (args is Product) {
            product = args;
          }
          return ProductFormScreen(
            productService: productService,
            product: product,
            user: user,
          );
        },
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final user = args is User
              ? args
              : User(username: 'Cashier', role: 'cashier');
          return HomePage(user: user);
        },
        '/sales': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final user = args is User
              ? args
              : User(username: 'Cashier', role: 'cashier');
          return SalesPage(
            user: user,
            productService: productService,
            saleService: saleService,
          );
        },
      },
    );
  }
}
