import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:practica_04/screens/auth.dart';
import 'package:practica_04/screens/new.dart';
import 'package:practica_04/screens/widgets/Menu.dart';
import 'package:practica_04/utils/api_endpoints.dart';
import 'package:practica_04/utils/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late List<dynamic> _newsList = [];

  @override
  void initState() {
    super.initState();
    _getNews();
  }

  Future<void> _getNews() async {
    try {
      final SharedPreferences? prefs = await _prefs;
      final String? token = prefs?.getString('token');

      final response = await http.get(
          Uri.parse(ApiEndPoints.baseUrl +
              ApiEndPoints.crudsEndpoints.news +
              "?status=true"),
          headers: {
            'Authorization': 'Bearer $token',
          });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _newsList = data['results'];
        });
      } else {
        throw jsonDecode(response.body)["msg"] ??
            "No se pudieron obtener las noticias :(";
      }
    } catch (error) {
      // Manejar error en la solicitud HTTP
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
      appBar: AppBar(actions: [
        TextButton(
            onPressed: () async {
              final SharedPreferences? prefs = await _prefs;
              prefs?.clear();
              Get.offAll(AuthScreen());
            },
            child: Text(
              'Salir',
              style: TextStyle(color: Colors.grey),
            ))
      ]),
      drawer: MenuDrawer(),
      body: Center(
        child: ListView.builder(
          itemCount: _newsList.length + 1, // +1 para el título "Noticias"
          itemBuilder: (context, index) {
            if (index == 0) {
              // Mostrar el título "Noticias" como el primer elemento de la lista
              return ListTile(
                title: Text(
                  'Noticias',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            final newsItem = _newsList[index -
                1]; // Restar 1 porque el primer elemento es el título "Noticias"
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen a la izquierda
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      newsItem['photo'].toString().isNotEmpty
                          ? Utils.replaceBaseUrl(newsItem['photo'])
                          : "",
                      height: 100.0,
                      width: 100.0,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return CircularProgressIndicator(); // Mostrar un indicador de carga mientras se carga la imagen
                        }
                      },
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        print('Error loading image: $exception');
                        return Text(
                            'Error al cargar la imagen'); // Mostrar un mensaje de error si no se puede cargar la imagen
                      },
                    ),
                  ),
                  SizedBox(
                      width:
                          16.0), // Espacio entre la imagen y el contenido de la noticia
                  // Contenido de la noticia a la derecha
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          newsItem['title'],
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          newsItem['body'],
                          style: TextStyle(color: Colors.black87),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          newsItem['type'],
                          style: TextStyle(
                            color: Colors.white,
                            backgroundColor: Colors.amber,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        SizedBox(
                          width: 100.0, // Ancho del botón "Ver"
                          child: ElevatedButton(
                            onPressed: () {
                              String newId = newsItem['id'].toString();
                              // Navegar a otra vista al presionar el botón "Ver"
                              // Aquí debes implementar la lógica para navegar a la vista deseada
                              Get.off(NewsView(newsId: newId));
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    12.0), // Bordes semi redondeados
                              ),
                            ),
                            child: Text(
                              'Ver',
                              style: TextStyle(color: Colors.lightBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
