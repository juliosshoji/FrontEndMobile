import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helloworld/controller/auth_service.dart';
import 'package:helloworld/model/customer_model.dart';
import 'package:helloworld/model/professional_model.dart';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers para os campos de texto
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _birthDateController;
  
  // Para prestadores
  late TextEditingController _specialtyController;
  late TextEditingController _contactAddressController;
  String _contactType = 'phone';
  List<String> _specialties = [];

  bool _isProvider = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    final provider = authService.currentProvider;
    
    _isProvider = authService.isProvider;

    if (_isProvider && provider != null) {
      _nameController = TextEditingController(text: provider.name);
      _birthDateController = TextEditingController(text: provider.birthday);
      _contactAddressController = TextEditingController(text: provider.contactAddress);
      _specialtyController = TextEditingController();
      _specialties = List.from(provider.specialties);
      _contactType = provider.contactType.isNotEmpty ? provider.contactType : 'phone';
      
      // Campos não usados por prestadores
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _addressController = TextEditingController();
    } else if (user != null) {
      _nameController = TextEditingController(text: user.name);
      _emailController = TextEditingController(text: user.email);
      _phoneController = TextEditingController(text: user.phone);
      _addressController = TextEditingController();
      _birthDateController = TextEditingController(text: user.birthDate);
      
      // Campos não usados por clientes
      _specialtyController = TextEditingController();
      _contactAddressController = TextEditingController();
    } else {
      // Inicializa vazio
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _addressController = TextEditingController();
      _birthDateController = TextEditingController();
      _specialtyController = TextEditingController();
      _contactAddressController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    _specialtyController.dispose();
    _contactAddressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      
      if (_isProvider) {
        await _updateProviderProfile(authService);
      } else {
        await _updateCustomerProfile(authService);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateCustomerProfile(AuthService authService) async {
    final currentUser = authService.currentUser!;
    
    final updatedCustomer = Customer(
      document: currentUser.document,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: currentUser.password,
      birthDate: _birthDateController.text.trim(),
    );

    await authService.updateCustomer(updatedCustomer);
  }

  Future<void> _updateProviderProfile(AuthService authService) async {
    final currentProvider = authService.currentProvider!;
    
    final updatedProvider = Professional(
      document: currentProvider.document,
      name: _nameController.text.trim(),
      birthday: _birthDateController.text.trim(),
      specialties: _specialties,
      contactType: _contactType,
      contactAddress: _contactAddressController.text.trim(),
      profilePhoto: currentProvider.profilePhoto,
    );

    await authService.updateProvider(updatedProvider);
  }

  Future<void> _updateProfilePhoto() async {
    // Simula upload de foto com um base64 válido
    const mockBase64Photo = 'iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHLAAAAABGdBTUEAALGOfPtRkwAAAAlwSFlzAAADsAAAA7AB6mFl+AAAAOklEQVR42u3BAQ0AAADCoftVb+pNB0xOTk5OTk5OTk5OTk5OTk5OTk5OTk5OTk5OTk5OTk7O/s4B62WwB0J6yU/HAAAAAElFTkSuQmCC';

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      
      if (_isProvider) {
        final currentProvider = authService.currentProvider!;
        final updatedProvider = Professional(
          document: currentProvider.document,
          name: currentProvider.name,
          birthday: currentProvider.birthday,
          specialties: currentProvider.specialties,
          contactType: currentProvider.contactType,
          contactAddress: currentProvider.contactAddress,
          profilePhoto: mockBase64Photo,
        );

        await authService.updateProvider(updatedProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apenas prestadores podem atualizar foto de perfil'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addSpecialty() {
    final specialty = _specialtyController.text.trim();
    if (specialty.isNotEmpty && !_specialties.contains(specialty.toUpperCase())) {
      setState(() {
        _specialties.add(specialty.toUpperCase());
        _specialtyController.clear();
      });
    }
  }

  void _removeSpecialty(String specialty) {
    setState(() {
      _specialties.remove(specialty);
    });
  }

  Widget _buildProfilePhoto() {
    final authService = context.watch<AuthService>();
    final profilePhoto = authService.currentProvider?.profilePhoto ?? '';
    
    Widget imageWidget;
    const double size = 100;

    if (profilePhoto.isNotEmpty) {
      try {
        final imageBytes = base64Decode(profilePhoto);
        imageWidget = ClipOval(
          child: Image.memory(
            imageBytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person, size: size, color: Colors.white);
            },
          ),
        );
      } catch (_) {
        imageWidget = const Icon(Icons.person, size: size, color: Colors.white);
      }
    } else {
      imageWidget = const Icon(Icons.person, size: size, color: Colors.white);
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: size / 2 + 5,
          backgroundColor: Colors.deepPurple,
          child: imageWidget,
        ),
        if (_isProvider)
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              radius: 18,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                padding: EdgeInsets.zero,
                onPressed: _updateProfilePhoto,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(child: _buildProfilePhoto()),
                    const SizedBox(height: 24),

                    // Nome
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nome é obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email (apenas para clientes)
                    if (!_isProvider) ...[
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email é obrigatório';
                          }
                          if (!value.contains('@')) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Telefone
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Data de Nascimento
                    TextFormField(
                      controller: _birthDateController,
                      decoration: const InputDecoration(
                        labelText: 'Data de Nascimento',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                        hintText: 'DD/MM/AAAA',
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 16),

                    // Campos específicos para prestadores
                    if (_isProvider) ...[
                      // Tipo de Contato
                      DropdownButtonFormField<String>(
                        value: _contactType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Contato',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.contact_page),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'phone', child: Text('Telefone')),
                          DropdownMenuItem(value: 'email', child: Text('Email')),
                          DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                        ],
                        onChanged: (value) => setState(() => _contactType = value!),
                      ),
                      const SizedBox(height: 16),

                      // Endereço de Contato
                      TextFormField(
                        controller: _contactAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Endereço de Contato',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.contact_mail),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Adicionar Especialidades
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _specialtyController,
                              decoration: const InputDecoration(
                                labelText: 'Adicionar Especialidade',
                                border: OutlineInputBorder(),
                                hintText: 'Ex: ELETRICIAN, GARDENER, COOK',
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            color: Colors.deepPurple,
                            iconSize: 36,
                            onPressed: _addSpecialty,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Lista de Especialidades
                      if (_specialties.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _specialties.map((specialty) {
                            return Chip(
                              label: Text(specialty),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeSpecialty(specialty),
                              backgroundColor: Colors.deepPurple.shade50,
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16),
                    ],

                    // Botão de salvar
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Salvar Alterações'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
