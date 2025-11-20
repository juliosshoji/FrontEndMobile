import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helloworld/controller/auth_service.dart';
import 'package:helloworld/view/services_session_screen.dart';
import 'package:provider/provider.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? _findCategoryFromSearch(String searchText) {
    if (searchText.trim().isEmpty) return null;
    
    final searchLower = searchText.toLowerCase().trim();
    final categories = {
      'jardineiro': 'Jardineiro',
      'jardim': 'Jardineiro',
      'jardinagem': 'Jardineiro',
      'marido de aluguel': 'Marido de Aluguel',
      'marido': 'Marido de Aluguel',
      'aluguel': 'Marido de Aluguel',
      'eletricista': 'Eletricista',
      'eletrica': 'Eletricista',
      'elétrica': 'Eletricista',
      'eletricidade': 'Eletricista',
      'encanador': 'Encanador',
      'encanamento': 'Encanador',
      'encanação': 'Encanador',
      'canos': 'Encanador',
      'diarista': 'Diarista',
      'faxina': 'Diarista',
      'limpeza': 'Diarista',
      'pintor': 'Pintor',
      'pintura': 'Pintor',
      'outro': 'Outro',
      'outros': 'Outro',
      'todos': 'Todos',
      'ver todos': 'Todos',
    };

    if (categories.containsKey(searchLower)) {
      return categories[searchLower];
    }

    for (var entry in categories.entries) {
      if (entry.key.contains(searchLower) || searchLower.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  void _performSearch() {
    final category = _findCategoryFromSearch(_searchController.text);
    if (category != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServicesSessionScreen(category: category),
        ),
      );
      _searchController.clear();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServicesSessionScreen(category: 'Todos'),
        ),
      );
      _searchController.clear();
    }
  }

  Widget _buildProfileIcon(BuildContext context, AuthService authService) {
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
    final authService = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(authService.isLoggedIn ? 'Bem-vindo!' : 'Entrar'),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildProfileIcon(context, authService),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Busque o serviço que precisa',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) {
                _performSearch();
              },
              textInputAction: TextInputAction.search,
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
          final authService = context.read<AuthService>();

          if (index == 0) {
            setState(() {
              _selectedIndex = 0;
            });
            return;
          }

          if ((index == 1 || index == 2) && !authService.isLoggedIn) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Você precisa fazer login para acessar esta área.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pushNamed(context, '/login');
            return;
          }

          String? routeName;
          if (index == 1) {
            routeName = '/favorites';
          } else if (index == 2) {
            routeName = '/my_services';
          }

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