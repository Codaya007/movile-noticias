import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:practica_04/screens/widgets/Menu.dart';
import 'package:practica_04/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditCommentPage extends StatefulWidget {
  final String commentId;

  EditCommentPage({required this.commentId});

  @override
  _EditCommentPageState createState() => _EditCommentPageState();
}

class _EditCommentPageState extends State<EditCommentPage> {
  final TextEditingController _commentController = TextEditingController();
  late LocationData _currentLocation;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getComment();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    _currentLocation = await location.getLocation();
  }

  Future<void> _getComment() async {
    try {
      final SharedPreferences? prefs = await _prefs;
      final String? token = prefs?.getString('token');

      final response = await http.get(
        Uri.parse('${ApiEndPoints.baseUrl}/comments/${widget.commentId}'),
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final commentData = json.decode(response.body);
        _commentController.text = commentData['results']['body'] ?? '';
      } else {
        throw Exception('No se pudo cargar el comentario :(');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _updateComment() async {
    try {
      final commentData = {
        'body': _commentController.text,
      };
      final SharedPreferences? prefs = await _prefs;
      final String? token = prefs?.getString('token');

      final response = await http.put(
        Uri.parse('${ApiEndPoints.baseUrl}/comments/${widget.commentId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(commentData),
      );

      if (response.statusCode == 200) {
        Navigator.pop(
            context); // Regresar a la pantalla anterior después de actualizar el comentario
      } else {
        throw Exception('No se pudo actualizar el comentario :(');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Comentario'),
      ),
      drawer: MenuDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comentario',
              ),
              maxLines: 4,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _updateComment();
              },
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
