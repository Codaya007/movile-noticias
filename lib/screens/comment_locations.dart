import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:practica_04/screens/widgets/Menu.dart';
import 'package:practica_04/utils/api_endpoints.dart';

class CommentLocationsView extends StatefulWidget {
  final String newsId;

  CommentLocationsView({required this.newsId});

  @override
  _CommentLocationsViewState createState() => _CommentLocationsViewState();
}

class _CommentLocationsViewState extends State<CommentLocationsView> {
  late List<dynamic> _coordinates = [];

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _getCommentCoordinates();
  }

  Future<void> _getCommentCoordinates() async {
    try {
      final response = await http.get(Uri.parse(ApiEndPoints.baseUrl +
          '/comments/coordinates?newsId=${widget.newsId}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        print(responseData.toString());

        setState(() {
          _coordinates = responseData['results'];
        });
      } else {
        throw Exception(
            'No se pudieron obtener las coordenadas de los comentarios :(');
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
      /**body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
      ), **/
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(-4.0329396, -79.2025477),
              zoom: 13,
            ),
            markers: _coordinates.map((coordinate) {
              return Marker(
                markerId: MarkerId(coordinate['id']),
                position: LatLng(coordinate['latitude']?.toDouble(),
                    coordinate['longitude']?.toDouble()),
              );
            }).toSet(),
          ),
        ],
      ),
    );
  }
}
