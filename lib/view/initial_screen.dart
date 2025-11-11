import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helloworld/controller/auth_service.dart';
import 'package:helloworld/view/services_session_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  // REMOVIDO: final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  Widget _buildProfileIcon(BuildContext context, AuthService authService) {
    // Esta função agora recebe o AuthService
    if (authService.isLoggedIn) {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/profile');
        },
        child: const CircleAvatar(
          child: Icon(Icons.person),
        ),
      );
    } else {
      return TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        child: const Text(
          'Login',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // CORREÇÃO: "Ouve" o AuthService para mudanças de estado (login/logout)
    final authService = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(authService.isLoggedIn ? 'Bem-vindo!' : 'Entrar'),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          // Passa o serviço para o helper
          child: _buildProfileIcon(context, authService),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Busque o serviço que precisa',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildServiceCard(
                      context, Icons.content_cut, 'Jardineiro', 'Jardineiro'),
                  _buildServiceCard(context, Icons.handyman, 'Marido de Aluguel',
                      'Marido de Aluguel'),
                  _buildServiceCard(
                      context, Icons.flash_on, 'Eletricista', 'Eletricista'),
                  _buildServiceCard(
                      context, Icons.water_drop, 'Encanador', 'Encanador'),
                  _buildServiceCard(
                      context, Icons.cleaning_services, 'Diarista', 'Diarista'),
                  _buildServiceCard(
                      context, Icons.format_paint, 'Pintor', 'Pintor'),
                  _buildServiceCard(
                      context, Icons.sentiment_satisfied_alt, 'Outro', 'Outro'),
                  _buildServiceCard(
                      context, Icons.check_box, 'Ver Todos', 'Todos'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
           if (index == 0) {
            setState(() {
              _selectedIndex = 0;
            });
            return;
          }

          String? routeName;
          if (index == 0) {
            // Já estamos aqui
          } else if (index == 1) {
            routeName = '/favorites';
          } else if (index == 2) {
            routeName = '/my_services';
          }
          // Atualiza o estado visual, exceto se já estiver na página 'home'
          if (routeName != null) {
            Navigator.pushNamed(context, routeName).then((_) {
              setState(() {
                _selectedIndex = 0;
              });
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favoritos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.work_history), label: 'Meus Serviços'),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, IconData icon, String label, String category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicesSessionScreen(category: category),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.purple),
            const SizedBox(height: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}