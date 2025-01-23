import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:meavisapp/controller/controller.dart';
import 'package:meavisapp/domain/entities.dart';

class Login extends StatefulWidget {
  final VoidCallback onRegister;
  final VoidCallback onLogin;
  final UserController userController;
  final UserLogged? userLogged;

  const Login(
      {super.key,
      required this.onRegister,
      required this.onLogin,
      required this.userController,
      this.userLogged});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final Logger logger = Logger();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  List<DropdownMenuEntry> ddds = [];

  String defaultLogin = "email";

  String preferenceNotification = "email";

  String? emailError;
  String? whatsappError;
  String? passwordError;

  String? loginError;

  String ddd = "84";

  bool _isLoading = false;

  void loading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void validateEmail(String? message) {
    String value = emailController.text;
    if ((defaultLogin == "email" || value.isNotEmpty) &&
        (!value.contains("@") || !value.contains(".") || value.length < 5)) {
      setState(() {
        emailError = message ?? "Digite um email válido\nEx: email@gmail.com";
      });
    } else {
      setState(() {
        emailError = null;
      });
    }
  }

  String validateWhatsapp(String? value) {
    value = value ?? whatsappController.text;
    String newValue = value.replaceAll("-", "");
    newValue = newValue.replaceAll(" ", "");
    newValue = newValue.replaceAll(",", "");
    newValue = newValue.replaceAll(".", "");

    if (newValue.length > 8) {
      newValue = newValue.substring(0, 8);
    }
    if (newValue.length > 4) {
      newValue = '${newValue.substring(0, 4)}-${newValue.substring(4)}';
    }

    if (newValue.length != 9 &&
        (defaultLogin == "whatsapp" || value.isNotEmpty)) {
      setState(() {
        whatsappError = "Digite um número válido";
      });
    } else {
      setState(() {
        whatsappError = null;
      });
    }
    return newValue;
  }

  void validatePassword(String? value) {
    value = value ?? passwordController.text;
    if (value.length < 6) {
      setState(() {
        passwordError = "Digite ao menos 6 caracteres";
      });
    } else {
      setState(() {
        passwordError = null;
      });
    }
  }

  @override
  void initState() {
    setState(() {
      widget.userController.getDDDs();
      ddds = widget.userController.ddds
          .map((ddd) =>
              DropdownMenuEntry(value: ddd.id, label: ddd.ddd.toString()))
          .toList();

      preferenceNotification =
          widget.userLogged?.preferenceNotification ?? "email";

      if (widget.userLogged != null) {
        if (preferenceNotification == "email") {
          defaultLogin = "email";
          emailController.text = widget.userLogged!.email!;
        } else if (preferenceNotification == "whatsapp") {
          defaultLogin = "whatsapp";
          ddd = widget.userLogged!.whatsapp!.substring(0, 2);
          whatsappController.text = widget.userLogged!.whatsapp!.substring(3);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    whatsappController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      padding: EdgeInsets.all(10),
      children: [
        Center(
          child: SizedBox(
              width: 400,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 20,
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Text(
                      "Acesse seus dados",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 56,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 20,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Entrar com",
                            ),
                            DropdownMenu(
                              dropdownMenuEntries: [
                                DropdownMenuEntry(value: 1, label: "Email"),
                                DropdownMenuEntry(value: 2, label: "Whatsapp"),
                              ],
                              initialSelection: defaultLogin == "email" ? 1 : 2,
                              onSelected: (value) {
                                if (_isLoading) {
                                  setState(() {
                                    if (value == 1) {
                                      defaultLogin = "email";
                                    } else {
                                      defaultLogin = "whatsapp";
                                    }
                                  });
                                }
                              },
                              inputDecorationTheme: InputDecorationTheme(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              menuStyle: MenuStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Theme.of(context).colorScheme.surface),
                                padding:
                                    WidgetStateProperty.all<EdgeInsetsGeometry>(
                                        EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 5,
                                            bottom: 5)),
                              ),
                            ),
                          ],
                        ),
                        if (defaultLogin == "email")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 5,
                            children: [
                              TextFormField(
                                controller: emailController,
                                maxLength: 100,
                                buildCounter: (BuildContext context,
                                    {required int currentLength,
                                    required int? maxLength,
                                    required bool isFocused}) {
                                  if (isFocused && emailError == null) {
                                    return Text("$currentLength/$maxLength");
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  if (_isLoading) {
                                    setState(() {
                                      emailController.value = TextEditingValue(
                                        text: value.replaceAll(" ", ""),
                                      );
                                    });
                                  }
                                },
                              ),
                              if (emailError != null)
                                Text(
                                  emailError!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        if (defaultLogin == "whatsapp")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 5,
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  DropdownMenu(
                                    label: Text(ddd),
                                    dropdownMenuEntries: ddds,
                                    initialSelection: ddd,
                                    width: 100,
                                    onSelected: (value) {
                                      if (_isLoading) {
                                        setState(() {
                                          ddd = ddds[value - 1].label;
                                        });
                                      }
                                    },
                                    inputDecorationTheme: InputDecorationTheme(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    menuStyle: MenuStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .surface),
                                      padding: WidgetStateProperty.all<
                                              EdgeInsetsGeometry>(
                                          EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 5,
                                              bottom: 5)),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: whatsappController,
                                      onChanged: (value) {
                                        if (_isLoading) {
                                          setState(() {
                                            whatsappController.value =
                                                TextEditingValue(
                                              text: validateWhatsapp(value),
                                            );
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: "Whatsapp",
                                        prefixText: "+55 $ddd 9 ",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              if (whatsappError != null)
                                Text(
                                  whatsappError!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        TextFormField(
                          obscureText: true,
                          controller: passwordController,
                          maxLength: 100,
                          buildCounter: (BuildContext context,
                              {required int currentLength,
                              required int? maxLength,
                              required bool isFocused}) {
                            if (isFocused && passwordError == null) {
                              return Text("$currentLength/$maxLength");
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            labelText: "Senha",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        if (passwordError != null)
                          Text(
                            passwordError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      spacing: 5,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            onPressed: () async {
                              if (_isLoading == false) {
                                loading(true);
                                try {
                                  validateEmail(null);
                                  validateWhatsapp(null);
                                  validatePassword(null);

                                  bool loginEmail = defaultLogin == "email" &&
                                      emailError == null;
                                  bool loginWhatsapp =
                                      defaultLogin == "whatsapp" &&
                                          whatsappError == null;

                                  if ((loginEmail || loginWhatsapp) &&
                                      passwordError == null) {
                                    logger.i("LoginPage: Tentando logar");

                                    String message;
                                    int code;
                                    (message, code) =
                                        await widget.userController.login(
                                      defaultLogin == "email"
                                          ? emailController.text
                                          : "${ddd}9${whatsappController.text}",
                                      defaultLogin,
                                      passwordController.text,
                                    );

                                    logger.i("LoginPage: $message");

                                    if (code == 200) {
                                      widget.onLogin();
                                    }

                                    if (code != 200) {
                                      setState(() {
                                        loginError = message;
                                      });
                                    }
                                  } else {
                                    logger.e("LoginPage: Formulário inválido");
                                    loginError =
                                        "Preencha todos os campos corretamente";
                                  }
                                } catch (e) {
                                  logger.e("LoginPage: Erro no login => $e");
                                  setState(() {
                                    loginError =
                                        "Erro acessando os dados, por favor entre em contato com a equipe";
                                  });
                                }

                                loading(false);
                              }
                            },
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  )
                                : Text(
                                    'Entrar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                        if (loginError != null)
                          Text(
                            loginError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    RichText(
                      text: TextSpan(
                        text: "Não tem uma conta? ",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Clique aqui",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = widget.onRegister,
                          ),
                          TextSpan(
                            text: " para se cadastrar",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )),
        )
      ],
    ));
  }
}
