import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helloworld/controller/professionals_controller.dart';
import 'package:helloworld/model/professional_model.dart';
import 'package:helloworld/view/provider_details_screen.dart';

class ServicesSessionScreen extends StatefulWidget {
  final String category;

  const ServicesSessionScreen({Key? key, required this.category})
      : super(key: key);

  @override
  _ServicesSessionScreenState createState() => _ServicesSessionScreenState();
}

class _ServicesSessionScreenState extends State<ServicesSessionScreen> {
  // REMOVIDO: final ProfessionalsController _controller = ProfessionalsController();
  late Future<List<Professional>> _professionals;

  @override
  void initState() {
    super.initState();
    // CORREÇÃO: Lê o controller do contexto
    _professionals = context
        .read<ProfessionalsController>()
        .fetchProfessionalsByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Cadastrados'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Busque o profissional em "${widget.category}"',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Professional>>(
              future: _professionals,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhum profissional encontrado.'));
                }

                final professionals = snapshot.data!;
                return ListView.builder(
                  itemCount: professionals.length,
                  itemBuilder: (context, index) {
                    final provider = professionals[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(provider.name),
                        subtitle: Text(provider.specialty),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProviderDetailsScreen(
                                professional: provider,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: ''),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      ),
    );
  }
}