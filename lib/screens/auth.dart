import 'package:practica_04/controllers/login_controller.dart';
import 'package:practica_04/controllers/register_controller.dart';
import 'package:practica_04/screens/widgets/inputs_fields.dart';
import 'package:practica_04/screens/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  RegisterController registerationController =
  Get.put(RegisterController());
  LoginController loginController = Get.put(LoginController());

  var isLogin = false.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(36),
          child: Center(
            child: Obx(
                  () => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      child: Text(
                        'Bienvenido',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          color: !isLogin.value ?  Colors.pinkAccent : Colors.white,
                          onPressed: () {
                            isLogin.value = false;
                          },
                          child: Text('Registrarse'),
                        ),
                        MaterialButton(
                          color: isLogin.value ?  Colors.pinkAccent : Colors.white,
                          onPressed: () {
                            isLogin.value = true;
                          },
                          child: Text('Iniciar sesión'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 80,
                    ),
                    isLogin.value ? loginWidget() : registerWidget()
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget registerWidget() {
    return Column(
      children: [
        InputTextFieldWidget(registerationController.nameController, 'Nombres'),
        SizedBox(
          height: 20,
        ),
        InputTextFieldWidget(registerationController.lastnameController, 'Apellidos'),
        SizedBox(
          height: 20,
        ),
        InputTextFieldWidget(registerationController.addressController, 'Dirección'),
        SizedBox(
          height: 20,
        ),
        InputTextFieldWidget(registerationController.phoneNumberController, 'Teléfono'),
        SizedBox(
          height: 20,
        ),
        InputTextFieldWidget(registerationController.birthdayController, 'Fecha de nacimiento'),
        SizedBox(
          height: 20,
        ),        InputTextFieldWidget(
            registerationController.emailController, 'Email'),
        SizedBox(
          height: 20,
        ),
        InputTextFieldWidget(
            registerationController.passwordController, 'Contraseña'),
        SizedBox(
          height: 20,
        ),
        SubmitButton(
          onPressed: () => registerationController.registerWithEmail(),
          title: 'Registrarse',
        )
      ],
    );
  }

  Widget loginWidget() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        InputTextFieldWidget(loginController.emailController, 'Email'),
        SizedBox(
          height: 20,
        ),
        InputTextFieldWidget(loginController.passwordController, 'Contraseña'),
        SizedBox(
          height: 20,
        ),
        SubmitButton(
          onPressed: () => loginController.loginWithEmail(),
          title: 'Ingresar',
        )
      ],
    );
  }
}