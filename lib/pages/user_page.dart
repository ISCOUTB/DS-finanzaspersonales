import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? userName;
  File? profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Usuario';
      final imagePath = prefs.getString('profileImage');
      if (imagePath != null) {
        profileImage = File(imagePath);
      }
    });
  }

  Future<void> _updateUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newName);
    setState(() {
      userName = newName;
    });
  }

  Future<void> _updateProfileImage(File newImage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImage', newImage.path);
    setState(() {
      profileImage = newImage;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      await _updateProfileImage(imageFile);
    }
  }

  void _showImageOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Opciones de Imagen'),
          content: const Text('¿Qué deseas hacer con la imagen de perfil?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _viewImage();
              },
              child: const Text('Ver Imagen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage();
              },
              child: const Text('Cambiar Imagen'),
            ),
          ],
        );
      },
    );
  }

  void _viewImage() {
    if (profileImage != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(profileImage!),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay imagen de perfil para mostrar.')),
      );
    }
  }

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(text: userName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Nombre'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Ingresa tu nuevo nombre'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _updateUserName(nameController.text);
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccountData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      userName = 'Usuario';
      profileImage = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Información de la cuenta eliminada.')),
    );
    Navigator.pop(context); // Regresa a la pantalla anterior
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar toda la información de tu cuenta? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el cuadro de diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el cuadro de diálogo
                _deleteAccountData(); // Elimina la información
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(225, 47, 125, 121),
                  Color.fromARGB(255, 246, 253, 250),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Contenido principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Foto de perfil
                GestureDetector(
                  onTap: _showImageOptionsDialog,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                        child: profileImage == null
                            ? const Icon(Icons.person, size: 70, color: Colors.white)
                            : null,
                        backgroundColor: const Color.fromARGB(225, 47, 125, 121),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.camera_alt, color: Color.fromARGB(225, 47, 125, 121)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Nombre de usuario
                Text(
                  userName ?? 'Usuario',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                // Botón de editar perfil
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _showEditNameDialog,
                  child: const Text(
                    'Editar Perfil',
                    style: TextStyle(
                      color: Color.fromARGB(225, 47, 125, 121),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Botón de eliminar cuenta
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _showDeleteConfirmationDialog,
                  child: const Text(
                    'Eliminar Información de la Cuenta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}