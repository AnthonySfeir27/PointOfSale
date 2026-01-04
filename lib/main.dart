import 'package:flutter/material.dart';
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
import 'models/product_model.dart';
import 'services/analytics_service.dart';
import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String apiBaseUrl = '${AppConstants.baseUrl}/users';

  @override
  Widget build(BuildContext context) {
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
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(userService: userService),
        '/signup': (_) => SignupScreen(userService: userService),
        '/dashboard': (_) =>
            DashboardScreen(analyticsService: analyticsService),
        '/products': (_) => ProductListScreen(productService: productService),
        '/edit-product': (context) {
          final product =
              ModalRoute.of(context)?.settings.arguments as Product?;
          return ProductFormScreen(
            productService: productService,
            product: product,
          );
        },
        '/home': (context) {
          final role =
              ModalRoute.of(context)?.settings.arguments as String? ??
              'cashier';
          return HomePage(role: role);
        },
        '/sales': (context) {
          final role =
              ModalRoute.of(context)?.settings.arguments as String? ??
              'cashier';
          return SalesPage(
            role: role,
            productService: productService,
            saleService: saleService,
          );
        },
      },
    );
  }
}
