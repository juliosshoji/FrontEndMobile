import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helloworld/controller/professionals_controller.dart';
import 'package:helloworld/model/professional_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Professional>> _favoriteProfessionals;

  @override
  void initState() {
    super.initState();
    _favoriteProfessionals =
        context.read<ProfessionalsController>().fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
      ),
      body: FutureBuilder<List<Professional>>(
        future: _favoriteProfessionals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Você ainda não favoritou nenhum profissional.'),
            );
          }

          final professionals = snapshot.data!;
          return ListView.builder(
            itemCount: professionals.length,
            itemBuilder: (context, index) {
              final professional = professionals[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(professional.name),
                subtitle: Text(professional.specialty),
                trailing: IconButton(
                  icon: const Icon(Icons.star, color: Colors.amber),
                  onPressed: () {
                    setState(() {
                      snapshot.data!.removeAt(index);
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
