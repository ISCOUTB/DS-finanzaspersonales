import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget reutilizable para mostrar el avatar de usuario en cualquier parte de la app.
class ProfileAvatar extends StatefulWidget {
  final double radius;
  final VoidCallback? onTap;
  const ProfileAvatar({Key? key, this.radius = 18, this.onTap}) : super(key: key);

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profileImage');
    setState(() {
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
      } else {
        _profileImage = null;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Escucha cambios cuando vuelve a la pantalla
    _loadProfileImage();
  }

  @override
  void didUpdateWidget(covariant ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
        child: _profileImage == null
            ? Icon(Icons.person, size: widget.radius, color: Colors.white)
            : null,
        backgroundColor: const Color.fromARGB(225, 47, 125, 121),
      ),
    );
  }
}
