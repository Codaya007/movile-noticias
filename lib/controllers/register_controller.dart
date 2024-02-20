import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:practica_04/screens/home.dart';
import 'package:practica_04/utils/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RegisterController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> registerWithEmail() async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var url = Uri.parse(
          ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.registerEmail);
      Map body = {
        'names': nameController.text,
        'lastnames': lastnameController.text,
        'phoneNumber': phoneNumberController.text,
        'birthday': birthdayController.text,
        'address': addressController.text,
        'email': emailController.text.trim(),
        'password': passwordController.text
      };

      print(body);

      http.Response response =
      await http.post(url, body: jsonEncode(body), headers: headers);

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);


        if (json['code'] == 201) {
         // var token = json['data']['Token'];
         // print(token);
         // final SharedPreferences? prefs = await _prefs;
          // await prefs?.setString('token', token);
          nameController.clear();
          emailController.clear();
          passwordController.clear();
          birthdayController.clear();
          addressController.clear();
          lastnameController.clear();
          phoneNumberController.clear();

          // Get.off(HomeScreen());
          showDialog(
              context: Get.context!,
              builder: (context) {
                return const SimpleDialog(
                  title: Text('Bienvenido'),
                  contentPadding: EdgeInsets.all(20),
                  children: [Text("Inicie sesión para continuar")],
                );
              });
        } else {
          throw jsonDecode(response.body)["msg"] ?? "Algo salió mal";
        }
      } else {
        throw jsonDecode(response.body)["msg"] ?? "Algo salió mal";
      }
    } catch (e) {
      Get.back();
      showDialog(
          context: Get.context!,
          builder: (context) {
            return SimpleDialog(
              title: const Text('Error'),
              contentPadding: const EdgeInsets.all(20),
              children: [Text(e.toString())],
            );
          });
    }
  }
}