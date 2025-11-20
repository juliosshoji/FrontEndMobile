import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helloworld/controller/auth_service.dart';
import 'package:helloworld/controller/professionals_controller.dart';
import 'package:helloworld/model/professional_model.dart';
import 'package:helloworld/view/evaluation_screen.dart';
import 'package:helloworld/provider/rest_provider.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'dart:convert';

extension ProfessionalCopyWith on Professional {
  Professional copyWith({
    String? document,
    String? name,
    String? birthday,
    List<String>? specialties,
    String? contactType,
    String? contactAddress,
    String? profilePhoto,
  }) {
    return Professional(
      document: document ?? this.document,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      specialties: specialties ?? this.specialties,
      contactType: contactType ?? this.contactType,
      contactAddress: contactAddress ?? this.contactAddress,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}

class ProviderDetailsScreen extends StatefulWidget {
  final Professional professional;

  const ProviderDetailsScreen({Key? key, required this.professional})
      : super(key: key);

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  late Professional _professional;

  @override
  void initState() {
    super.initState();
    _professional = widget.professional;
  }

  void _handleAction(BuildContext context, VoidCallback onLoggedIn) {
    final authService = context.read<AuthService>();

    if (authService.isLoggedIn) {
      onLoggedIn();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para realizar esta ação.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Uint8List? _decodeBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;

    try {
      String cleanString = base64String;
      if (base64String.contains(',')) {
        cleanString = base64String.split(',').last;
      }

      cleanString = cleanString.replaceAll(RegExp(r'\s+'), '');

      return base64Decode(cleanString);
    } catch (e) {
      print('Erro ao decodificar imagem Base64: $e');
      return null;
    }
  }

  Future<void> _contactProvider(
      BuildContext context, String url, String contactType) async {
    final authService = context.read<AuthService>();
    final restProvider = context.read<RestProvider>();

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (authService.isLoggedIn && authService.currentUser != null) {
        try {
          await restProvider.addServiceHistory(
            authService.currentUser!.document,
            _professional.document,
          );
          print("Serviço adicionado ao histórico com sucesso.");
        } catch (e) {
          print("Erro ao salvar histórico: $e");
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o $contactType.')),
      );
    }
  }

  void _showFullProfilePhoto(BuildContext context) {
    if (_professional.profilePhoto?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este prestador não possui foto de perfil.')),
      );
      return;
    }

    try {
      final imageBytes = base64Decode(_professional.profilePhoto ?? '');
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar a foto: O formato Base64 é inválido ou incompleto.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // FUNÇÃO DE SIMULAÇÃO CORRIGIDA COM BASE64 VÁLIDO E MAIS LONGO
  void _simulateUploadAndUpdatePhoto(BuildContext context) async {
    // String Base64 MAIS LONGA E VÁLIDA (Representa um ícone/imagem simples)
    // Isso evita o erro de formato ao tentar decodificar uma string muito curta ou inválida.
    const mockBase64Photo = 'iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHLAAAAABGdBTUEAALGOfPtRkwAAAAlwSFlzAAADsAAAA7AB6mFl+AAAAOklEQVR42u3BAQ0AAADCoftVb+pNB0xOTk5OTk5OTk5OTk5OTk5OTk5OTk5OTk5OTk5OTk7O/s4B62WwB0J6yU/HAAAAAElFTkSuQmCC';

    _handleAction(context, () async {
      try {
        // Atualiza o estado local para exibir a nova foto imediatamente (simulação)
        setState(() {
          _professional = _professional.copyWith(profilePhoto: mockBase64Photo);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil atualizada com sucesso (simulação)!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }


  Widget _buildProfilePhoto() {
    const double size = 120;
    final imageBytes = _decodeBase64(_professional.profilePhoto);

<<<<<<< Updated upstream
    if (_professional.profilePhoto?.isNotEmpty ?? false) {
      try {
        final imageBytes = base64Decode(_professional.profilePhoto ?? '');
        imageWidget = ClipOval(
          child: Image.memory(
            imageBytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback se a decodificação funcionar, mas o Flutter não conseguir renderizar a imagem
              return Icon(Icons.person, size: size, color: Colors.white);
            },
          ),
        );
      } catch (_) {
        // Caso a string Base64 seja inválida
        imageWidget = Icon(Icons.broken_image, size: size, color: Colors.white);
      }
    } else {
      // Placeholder se não houver foto
      imageWidget = Icon(Icons.person, size: size, color: Colors.white);
=======
    Widget imageWidget;
    if (imageBytes != null) {
      imageWidget = ClipOval(
        child: Image.memory(
          imageBytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image, size: size / 2, color: Colors.white);
          },
        ),
      );
    } else {
      imageWidget = Icon(Icons.person, size: size / 2, color: Colors.white);
>>>>>>> Stashed changes
    }

    // O GestureDetector permite o clique para ver a foto em tamanho maior
    return GestureDetector(
      onTap: () {
        if (imageBytes != null) {
            showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.black,
                child: Stack(
                  children: [
                    Center(child: Image.memory(imageBytes, fit: BoxFit.contain)),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Imagem indisponível.')),
            );
        }
      },
      child: CircleAvatar(
        radius: size / 2 + 5,
        backgroundColor: Colors.deepPurple,
        child: imageWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // Prepara URLs (remove caracteres não numéricos do telefone)
    final cleanPhone = _professional.contactAddress.replaceAll(RegExp(r'[^0-9]'), '');
<<<<<<< Updated upstream
    final whatsappUrl = "https://wa.me/55$cleanPhone"; // Assumindo +55 Brasil
    final phoneUrl = "tel:$cleanPhone";
=======
    final whatsappUrl = "https://wa.me/55$cleanPhone";
>>>>>>> Stashed changes

    return Scaffold(
      appBar: AppBar(
        title: Text(_professional.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {
              _handleAction(context, () async {
                final customer = context.read<AuthService>().currentUser;
                if (customer == null) return; 

                final controller = context.read<ProfessionalsController>();

                try {
                  await controller.addFavorite(customer.document, _professional.document);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profissional adicionado aos favoritos!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildProfilePhoto()),
            const SizedBox(height: 24),

            Text(_professional.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(_professional.specialty, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              icon: const Icon(Icons.phone),
              label: const Text('Contatar (WhatsApp/Tel)'),
              onPressed: () {
                _handleAction(context, () {
                  _contactProvider(context, whatsappUrl, "WhatsApp");
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            
            const SizedBox(height: 16),
            // Botão de simulação para upload de foto (disponível quando logado)
            if (authService.isLoggedIn)
              OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Simular Upload de Foto'),
                onPressed: () => _simulateUploadAndUpdatePhoto(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Deixar uma Avaliação'),
              onPressed: () {
                _handleAction(context, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EvaluationScreen(
                        professionalName: _professional.name,
                        providerId: _professional.document,
                      ),
                    ),
                  );
                });
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const Divider(height: 40),
            Text('Avaliações', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}