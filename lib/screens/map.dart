import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:practica_04/screens/widgets/Menu.dart';

class CommentLocationsView extends StatefulWidget {
  final String newsId;

  CommentLocationsView({required this.newsId});

  @override
  _CommentLocationsViewState createState() => _CommentLocationsViewState();
}

class _CommentLocationsViewState extends State<CommentLocationsView> {
  late List<dynamic> _coordinates = [];

  @override
  void initState() {
    super.initState();
    _getCommentCoordinates();
  }

  Future<void> _getCommentCoordinates() async {
    try {
      final response = await http.get(
          Uri.parse('/comments/coordinates?newsId=${widget.newsId}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _coordinates = responseData['results'];
        });
      } else {
        throw Exception('No se pudieron obtener las coordenadas de los comentarios :(');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicaciones de Comentarios'),
      ),
      drawer: MenuDrawer(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(0, 0),
              zoom: 1,
            ),
            markers: _coordinates.map((coordinate) {
              return Marker(
                markerId: MarkerId(coordinate['id']),
                position: LatLng(coordinate['latitude'], coordinate['longitude']),
              );
            }).toSet(),
          ),
        ],
      ),
    );
  }
}
