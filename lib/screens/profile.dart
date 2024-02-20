import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practica_04/screens/widgets/Menu.dart';
import 'package:practica_04/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({Key? key}) : super(key: key);

  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  late Map<String, dynamic> _userData = {};
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final SharedPreferences? prefs = await _prefs;
      final String? token = prefs?.getString('token');
      var headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
      final response = await http.get(Uri.parse('${ApiEndPoints.baseUrl}/users/me'), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body)['results'];
        setState(() {
          _userData = userData;
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
            Text(
              'Nombres: ${_userData['names']}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Apellidos: ${_userData['lastnames']}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Dirección: ${_userData['address']}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Teléfono: ${_userData['phoneNumber']}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Fecha de Nacimiento: ${_userData['birthDate']}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 8.0),
            Text(
              'Rol: ${_userData['role']['name']}',
              style: TextStyle(fontSize: 18.0),
            ),
            ElevatedButton(
              onPressed: () {
                // Agregar lógica para añadir comentario
              },
              style: ElevatedButton.styleFrom(
                // primary: Colors.pinkAccent,
                // onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('Editar'),
            ),
          ],
        ),
      ),
    );
  }
}
