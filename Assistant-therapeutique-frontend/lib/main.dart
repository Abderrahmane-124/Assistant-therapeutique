import 'package:flutter/material.dart';


import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';

import 'features/home/pages/home_page.dart';

import 'ui/styles/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),

     
      home: const LoginPage(),
    );
  }
}
