import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:practica_04/screens/widgets/Menu.dart';
import 'package:practica_04/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCommentView extends StatefulWidget {
  final String newsId;

  AddCommentView({required this.newsId});

  @override
  _AddCommentViewState createState() => _AddCommentViewState();
}

class _AddCommentViewState extends State<AddCommentView> {
  final TextEditingController _commentController = TextEditingController();
  late LocationData _currentLocation;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    _currentLocation = await location.getLocation();
  }

  Future<void> _addComment() async {
    try {
      final commentData = {
        'body': _commentController.text,
        'status': true,
        'latitude': _currentLocation.latitude,
        'longitude': _currentLocation.longitude,
        'newsId': widget.newsId,
      };
      final SharedPreferences? prefs = await _prefs;
      final String? token = prefs?.getString('token');

      final response = await http.post(
        Uri.parse(ApiEndPoints.baseUrl + '/comments'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(commentData),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context); // Regresar a la pantalla anterior después de añadir el comentario
      } else {
        throw Exception('No se pudo añadir el comentario :(');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Comentario'),
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
                _addComment();
              },
              child: Text('Añadir Comentario'),
            ),
          ],
        ),
      ),
    );
  }
}
