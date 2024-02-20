import 'package:flutter/material.dart';
import 'package:practica_04/screens/auth.dart';
import 'package:practica_04/screens/home.dart';
import 'package:practica_04/screens/my_comments.dart';
import 'package:practica_04/screens/profile.dart';
import "package:get/get.dart";

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menú',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Perfil'),
            onTap: () {
              Get.off(const UserProfileView());
            },
          ),
          ListTile(
            title: Text('Mis Comentarios'),
            onTap: () {
              // Navegar a la página de comentarios del usuario
              Get.off(const MyNewsView());
            },
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              // Navegar a la página principal (Home)
              Get.off(const HomeScreen());
            },
          ),
          ListTile(
            title: Text('Salir'),
            onTap: () {
              // Realizar acciones de cierre de sesión, por ejemplo
              Get.back();
              showDialog(
                  context: Get.context!,
                  builder: (context) {
                    return SimpleDialog(
                      title: const Text('Cerrar sesión'),
                      contentPadding: const EdgeInsets.all(20),
                      children: [Text("Vuelva pronto usuario")],
                    );
                  });
              Get.off(AuthScreen());
            },
          ),
        ],
      ),
    );
  }
}
