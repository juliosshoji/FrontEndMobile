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
  final TextEditingController _searchController = TextEditingController();
  List<Professional> _allProfessionals = [];
  List<Professional> _filteredProfessionals = [];

  @override
  void initState() {
    super.initState();
    // CORREÇÃO: Lê o controller do contexto
    _professionals = context
        .read<ProfessionalsController>()
        .fetchProfessionalsByCategory(widget.category);
    _professionals.then((professionals) {
      setState(() {
        _allProfessionals = professionals;
        // Se já há texto de busca, aplica o filtro
        final query = _searchController.text.toLowerCase().trim();
        if (query.isEmpty) {
          _filteredProfessionals = professionals;
        } else {
          _filteredProfessionals = professionals.where((professional) {
            final nameMatch = professional.name.toLowerCase().contains(query);
            final specialtyMatch = professional.specialties.any(
              (specialty) => specialty.toLowerCase().contains(query),
            );
            final contactMatch = professional.contactAddress.toLowerCase().contains(query);
            return nameMatch || specialtyMatch || contactMatch;
          }).toList();
        }
      });
    });
    _searchController.addListener(_filterProfessionals);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProfessionals);
    _searchController.dispose();
    super.dispose();
  }

  void _filterProfessionals() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredProfessionals = _allProfessionals;
      } else {
        _filteredProfessionals = _allProfessionals.where((professional) {
          final nameMatch = professional.name.toLowerCase().contains(query);
          final specialtyMatch = professional.specialties.any(
            (specialty) => specialty.toLowerCase().contains(query),
          );
          final contactMatch = professional.contactAddress.toLowerCase().contains(query);
          return nameMatch || specialtyMatch || contactMatch;
        }).toList();
      }
    });
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Busque o profissional em "${widget.category}"',
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {});
              },
              textInputAction: TextInputAction.search,
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

                // Sempre usa a lista filtrada quando há dados carregados
                final List<Professional> professionals;
                if (_allProfessionals.isNotEmpty) {
                  // Usa a lista filtrada (já foi inicializada no .then() e atualizada pelo listener)
                  professionals = _filteredProfessionals;
                } else {
                  // Ainda não tem dados carregados, usa do snapshot
                  professionals = snapshot.data ?? [];
                }

                // Verifica se há busca e não encontrou resultados
                final hasSearchText = _searchController.text.trim().isNotEmpty;
                final hasNoResults = professionals.isEmpty && hasSearchText && _allProfessionals.isNotEmpty;
                
                if (hasNoResults) {
                  return const Center(
                      child: Text('Profissional não encontrado'));
                }
                
                // Se não há dados carregados ainda, mostra lista do snapshot
                if (_allProfessionals.isEmpty && professionals.isEmpty) {
                  return const Center(
                      child: Text('Nenhum profissional encontrado.'));
                }

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