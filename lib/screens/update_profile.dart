import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:practica_04/screens/profile.dart';
import 'package:practica_04/screens/widgets/Menu.dart';
import 'package:practica_04/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateUserProfile extends StatefulWidget {
  final String newsId;
  const UpdateUserProfile({Key? key, required this.newsId}) : super(key: key);

  @override
  _UpdateUserProfileState createState() => _UpdateUserProfileState();
}

class _UpdateUserProfileState extends State<UpdateUserProfile> {
  late Map<String, dynamic> _userData = {};
  final TextEditingController _namesController = TextEditingController();
  final TextEditingController _lastnamesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _updateProfile() async {
    try {
      final SharedPreferences? prefs = await _prefs;
      final String? token = prefs?.getString('token');

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

// Obtener los nuevos valores de los campos de texto
      String names = _namesController.text;
      String lastnames = _lastnamesController.text;
      String address = _addressController.text;
      String phoneNumber = _phoneNumberController.text;
      String birthDate = _birthDateController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

// Crear el mapa con los nuevos valores
      final body = {
        'names': names,
        'lastnames': lastnames,
        'address': address,
        'phoneNumber': phoneNumber,
        'birthDate': birthDate,
        'email': email,
        // 'password': password,
      };

      // Añadir la contraseña al mapa si no está vacía
      if (password.isNotEmpty) {
        body['password'] = password;
      }

      final response = await http.put(
          Uri.parse('${ApiEndPoints.baseUrl}/users/${widget.newsId}'),
          headers: headers,
          body: jsonEncode(body));

      if (response.statusCode == 201) {
        showDialog(
            context: Get.context!,
            builder: (context) {
              return const SimpleDialog(
                title: const Text('Exito'),
                contentPadding: const EdgeInsets.all(20),
                children: [Text("Perfil actualizado exitosamente!")],
              );
            });
        Get.off(const UserProfileView());
      } else {
        throw Exception('No se pudo actualizar el perfil del usuario :(');
      }
    } catch (error) {
      print(error.toString());
      Get.back();
      showDialog(
          context: Get.context!,
          builder: (context) {
            return SimpleDialog(
              title: const Text('Error'),
              contentPadding: const EdgeInsets.all(20),
              children: [Text(error.toString())],
            );
          });
    }
  }

  Future<void> _getUserData() async {
    try {
      final SharedPreferences? prefs = await _prefs;
      final String? token = prefs?.getString('token');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      final response = await http
          .get(Uri.parse('${ApiEndPoints.baseUrl}/users/me'), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData =
            json.decode(response.body)['results'];
        setState(() {
          _userData = userData;
          _namesController.text = _userData['names'];
          _lastnamesController.text = _userData['lastnames'];
          _addressController.text = _userData['address'];
          _phoneNumberController.text = _userData['phoneNumber'];
          _birthDateController.text = _userData['birthDate'];
          _emailController.text = _userData['account']['email'];
          _passwordController.text = '';
        });
      } else {
        throw Exception('No se pudo cargar el perfil del usuario :(');
      }
    } catch (error) {
      // Manejar errores
      print(error.toString());
      Get.back();
      showDialog(
          context: Get.context!,
          builder: (context) {
            return SimpleDialog(
              title: const Text('Error'),
              contentPadding: const EdgeInsets.all(20),
              children: [Text(error.toString())],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
      ),
      drawer: MenuDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _namesController,
              decoration: InputDecoration(labelText: 'Nombres'),
            ),
            TextFormField(
              controller: _lastnamesController,
              decoration: InputDecoration(labelText: 'Apellidos'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Dirección'),
            ),
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Teléfono'),
            ),
            TextFormField(
              controller: _birthDateController,
              decoration: InputDecoration(labelText: 'Fecha de Nacimiento'),
            ),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('Actualizar Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
