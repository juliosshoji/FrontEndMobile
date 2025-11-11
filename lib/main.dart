import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helloworld/controller/auth_service.dart';
import 'package:helloworld/controller/professionals_controller.dart';
import 'package:helloworld/controller/reviews_controller.dart';
import 'package:helloworld/controller/services_controller.dart';
import 'package:helloworld/provider/rest_provider.dart';
import 'package:helloworld/view/evaluation_screen.dart';
import 'package:helloworld/view/favorites_screen.dart';
import 'package:helloworld/view/initial_screen.dart';
import 'package:helloworld/view/login_screen.dart';
import 'package:helloworld/view/my_services_screen.dart';
import 'package:helloworld/view/profile_screen.dart';
import 'package:helloworld/view/provider_registration_screen.dart';
import 'package:helloworld/view/registration_screen.dart';
import 'package:helloworld/view/release_evaluation_screen.dart';
import 'package:helloworld/view/review_screen.dart';
import 'package:helloworld/view/services_session_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Fornece a camada de API primeiro (não tem dependências)
        Provider<RestProvider>(
          create: (_) => RestProvider(),
        ),

        // 2. Fornece o ServicesController (não tem dependências)
        Provider<ServicesController>(
          create: (_) => ServicesController(),
        ),

        // 3. Usa ProxyProviders para construir os serviços
        //    que DEPENDEM do RestProvider.
        ProxyProvider<RestProvider, AuthService>(
          update: (context, api, previous) => AuthService(api: api),
        ),
        ProxyProvider<RestProvider, ProfessionalsController>(
          update: (context, api, previous) =>
              ProfessionalsController(api: api),
        ),
        ProxyProvider<RestProvider, ReviewsController>(
          update: (context, api, previous) => ReviewsController(api: api),
        ),
      ],
      child: MaterialApp(
        title: 'Service Finder App',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: Colors.grey[200],
          visualDensity: VisualDensity.adaptivePlatformDensity,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Corrigido de 'primary'
              foregroundColor: Colors.deepPurple, // Corrigido de 'onPrimary'
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const InitialScreen(),
          '/login': (context) => const LoginScreen(),
          '/registration': (context) => const RegistrationScreen(),
          '/services_session': (context) =>
              const ServicesSessionScreen(category: ''),
          '/evaluation': (context) =>
              const EvaluationScreen(professionalName: '', providerId: ''),
          '/release_evaluations': (context) =>
              const ReleaseEvaluationsScreen(),
          '/reviews': (context) =>
              const ReviewsScreen(professionalName: '', providerId: ''),
          '/favorites': (context) => const FavoritesScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/provider_registration': (context) =>
              const ProviderRegistrationScreen(),
          '/my_services': (context) => const MyServicesScreen(),
        },
      ),
    );
  }
}