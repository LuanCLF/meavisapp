import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:meavisa/controller/controller.dart';
import 'package:meavisa/domain/entities.dart';

class Profile extends StatefulWidget {
  final VoidCallback onLogout;
  final UserLogged userLogged;
  final UserController userController;
  const Profile(
      {super.key,
      required this.onLogout,
      required this.userLogged,
      required this.userController});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final logger = Logger();

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  List<DropdownMenuEntry> categories = [];
  List<DropdownMenuEntry> locations = [];
  List<DropdownMenuEntry> ddds = [];

  late UserLogged userLogged;
  String? successMessage;

  String ddd = "84";
  String preferenceNotification = "email";

  List<String> userPreferenceCategory = [];
  String? userLocation;

  bool _isLoading = false;

  List<String> errors = [];
  String? registerError;

  void registerErrorF(String? message) {
    setState(() {
      if (message != null) {
        registerError = message;
        if (!errors.contains("form")) errors.add("form");
      } else if (errors.contains("form")) {
        registerError = null;
        errors.remove("form");
      }
    });
  }

  void loading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void validatePreferenceCategory() {
    if (userPreferenceCategory.isEmpty) {
      errors.add("category");
    } else {
      errors.remove("category");
    }
  }

  void validateCategory(bool value, DropdownMenuEntry<dynamic> category) {
    if (value) {
      userPreferenceCategory.add(category.label);
    } else {
      userPreferenceCategory.remove(category.label);
    }

    validatePreferenceCategory();
  }

  String formatName() {
    List<String> words = nameController.text.trim().split(" ");
    String formatted = "";
    for (String word in words) {
      word = word.trim();
      formatted += word[0].toUpperCase() + word.substring(1).toLowerCase();
      formatted += " ";
    }
    return formatted;
  }

  void validateName(String? value) {
    value = value ?? nameController.text;
    if (value.length < 3) {
      if (!errors.contains("name")) errors.add("name");
    } else {
      errors.remove("name");
    }
  }

  void validateEmail(String? value) {
    value = value ?? emailController.text;
    if ((preferenceNotification == "email" || value.isNotEmpty) &&
        (!value.contains("@") || !value.contains(".") || value.length < 5)) {
      if (!errors.contains("email")) errors.add("email");
    } else {
      errors.remove("email");
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
        (preferenceNotification == "whatsapp" || value.isNotEmpty)) {
      if (!errors.contains("whatsapp")) errors.add("whatsapp");
    } else {
      errors.remove("whatsapp");
    }
    return newValue;
  }

  void validatePassword(String? value) {
    if (passwordController.text.isNotEmpty) {
      value = value ?? passwordController.text;
      if (value.length < 6) {
        if (!errors.contains("password")) errors.add("password");
      } else {
        errors.remove("password");
      }
    } else {
      errors.remove("password");
    }
  }

  Future<void> _initializeData() async {
    await widget.userController.getCategories();
    await widget.userController.getLocations();
    await widget.userController.getDDDs();

    setState(() {
      categories = widget.userController.categories
          .map((category) =>
              DropdownMenuEntry(value: category.id, label: category.category))
          .toList();

      locations = widget.userController.locations
          .map((location) =>
              DropdownMenuEntry(value: location.id, label: location.location))
          .toList();

      ddds = widget.userController.ddds
          .map((ddd) =>
              DropdownMenuEntry(value: ddd.id, label: ddd.ddd.toString()))
          .toList();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    whatsappController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    userLogged = widget.userLogged;
    userPreferenceCategory = userLogged.categories;
    userLocation = userLogged.location;
    preferenceNotification = userLogged.preferenceNotification;
    nameController.text = userLogged.name;
    emailController.text = userLogged.email ?? "";
    whatsappController.text = userLogged.whatsapp?.substring(3) ?? "";
    ddd = userLogged.whatsapp?.substring(0, 2) ?? "84";

    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      padding: EdgeInsets.all(10),
      children: [
        Form(
            child: SizedBox(
          child: Column(
            children: [
              SizedBox(
                height: 60,
              ),
              Text(
                'Suas Preferências',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 56,
                ),
              ),
              SizedBox(
                width: 250,
                child: Text(
                  'Atualize da forma que desejar!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 35,
              ),
              SizedBox(
                  width: 400,
                  child: Column(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        spacing: 30,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Categorias selecionadas:"),
                              for (DropdownMenuEntry<dynamic> category
                                  in categories)
                                Row(
                                  children: [
                                    Checkbox(
                                      value: userPreferenceCategory
                                          .contains(category.label),
                                      onChanged: (value) {
                                        if (_isLoading == false) {
                                          setState(() {
                                            validateCategory(
                                                value == true, category);
                                          });
                                        }
                                      },
                                    ),
                                    Text(category.label),
                                  ],
                                ),
                              if (errors.contains("category") &&
                                  userPreferenceCategory.isEmpty)
                                Text(
                                  "Selecione ao menos\numa categoria",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 20,
                            children: [
                              DropdownMenu(
                                label: userLocation == null
                                    ? const Text("Bairro")
                                    : Text(
                                        userLocation!,
                                        style: TextStyle(
                                          height: 1.2,
                                        ),
                                      ),
                                dropdownMenuEntries: locations,
                                initialSelection: userLocation,
                                width: 165,
                                onSelected: (value) {
                                  if (_isLoading == false) {
                                    setState(() {
                                      userLocation = locations[value - 1].label;
                                    });
                                  }
                                },
                                inputDecorationTheme: InputDecorationTheme(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                menuStyle: MenuStyle(
                                  backgroundColor: WidgetStateProperty.all<
                                          Color>(
                                      Theme.of(context).colorScheme.surface),
                                  padding: WidgetStateProperty
                                      .all<EdgeInsetsGeometry>(EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 5,
                                          bottom: 10)),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Meio de notificação:"),
                                  Row(
                                    children: [
                                      Checkbox(
                                          value:
                                              preferenceNotification == "email",
                                          semanticLabel: "Email",
                                          onChanged: (value) {
                                            if (_isLoading == false) {
                                              setState(() {
                                                preferenceNotification =
                                                    value == true
                                                        ? "email"
                                                        : "whatsapp";
                                              });
                                            }
                                          }),
                                      Text("Email"),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Checkbox(
                                          value: preferenceNotification ==
                                              "whatsapp",
                                          semanticLabel: "Whatsapp",
                                          onChanged: (value) {
                                            if (_isLoading == false) {
                                              setState(() {
                                                preferenceNotification =
                                                    value == true
                                                        ? "whatsapp"
                                                        : "email";
                                              });
                                            }
                                          }),
                                      Text("Whatsapp"),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          TextFormField(
                            controller: nameController,
                            maxLength: 100,
                            buildCounter: (BuildContext context,
                                {required int currentLength,
                                required int? maxLength,
                                required bool isFocused}) {
                              if (isFocused && !errors.contains("name")) {
                                return Text("$currentLength/$maxLength");
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              labelText: "Nome",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onChanged: (value) {
                              if (_isLoading == false) {
                                setState(() {
                                  value = value.replaceAll(RegExp(r'\s+'), ' ');

                                  validateName(value);

                                  nameController.value = TextEditingValue(
                                    text: value,
                                  );
                                });
                              }
                            },
                          ),
                          if (errors.contains("name"))
                            Text(
                              "Digite ao menos 3 caracteres",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
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
                              if (isFocused && !errors.contains("email")) {
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
                              if (_isLoading == false) {
                                setState(() {
                                  value = value.replaceAll(" ", "");

                                  validateEmail(value);

                                  emailController.value = TextEditingValue(
                                    text: value,
                                  );
                                });
                              }
                            },
                          ),
                          if (errors.contains("email"))
                            Text(
                              "Digite um email válido\nEx: email@gmail.com",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
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
                                  if (_isLoading == false) {
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
                                  backgroundColor: WidgetStateProperty.all<
                                          Color>(
                                      Theme.of(context).colorScheme.surface),
                                  padding: WidgetStateProperty
                                      .all<EdgeInsetsGeometry>(EdgeInsets.only(
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
                                    if (_isLoading == false) {
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
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          if (errors.contains("whatsapp"))
                            Text(
                              "Digite um número válido",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
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
                              if (isFocused && !errors.contains("password")) {
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
                            onChanged: (value) {
                              if (_isLoading == false) {
                                setState(() {
                                  validatePassword(value);
                                });
                              }
                            },
                          ),
                          if (errors.contains("password"))
                            Text(
                              "Digite ao menos 6 caracteres",
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 150,
                                height: 50,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    side: WidgetStateProperty.all<BorderSide>(
                                      BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  onPressed: widget.onLogout,
                                  child: Text(
                                    'Sair',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                spacing: 5,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (_isLoading == false) {
                                          try {
                                            loading(true);
                                            setState(() {
                                              errors.remove("form");
                                              successMessage = null;
                                            });
                                            validatePreferenceCategory();
                                            validateName(null);
                                            validateEmail(null);
                                            validateWhatsapp(null);
                                            validatePassword(null);

                                            if (errors.isEmpty ||
                                                (errors.contains("password") &&
                                                    passwordController
                                                        .text.isEmpty)) {
                                              logger.i(
                                                  "ProfilePage: Formulário válido");
                                              String? emailC =
                                                  emailController.text.isEmpty
                                                      ? null
                                                      : emailController.text;

                                              String? whatsappC = whatsappController
                                                      .text.isEmpty
                                                  ? null
                                                  : "${ddd}9${whatsappController.text}";

                                              String message;
                                              int code;

                                              (message, code) = await widget
                                                  .userController
                                                  .updateUser(User(
                                                id: userLogged.id,
                                                name: formatName().trim(),
                                                email: emailC,
                                                whatsapp: whatsappC,
                                                password:
                                                    passwordController.text,
                                                categories:
                                                    userPreferenceCategory,
                                                location: userLocation,
                                                preferenceNotification:
                                                    preferenceNotification,
                                              ));

                                              if (code == 204) {
                                                setState(() {
                                                  successMessage =
                                                      "Dados atualizados com sucesso!";
                                                });
                                              }

                                              if (code == 409) {
                                                registerErrorF(message);
                                              }

                                              if (code == 500) {
                                                registerErrorF(message);
                                              }
                                            } else {
                                              logger.e(
                                                  "ProfilePage: Formulário inválido => $errors");

                                              registerErrorF(
                                                  "Preencha todos os campos corretamente");
                                            }
                                          } catch (e) {
                                            logger.e(
                                                "ProfilePage: Erro na atualização => $e");
                                            registerErrorF(
                                                "Erro atualizando dados, por favor entre em contato com a equipe");
                                          }
                                          loading(false);
                                        }
                                      },
                                      child: _isLoading
                                          ? CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary),
                                            )
                                          : Text(
                                              'Atualizar',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (successMessage != null)
                            Text(
                              successMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                              ),
                            ),
                          if (errors.contains("form"))
                            Text(
                              registerError ??
                                  "Erro atualizando dados, por favor entre em contato com a equipe",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        ))
      ],
    ));
  }
}
