import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:meavisapp/controller/controller.dart';
import 'package:meavisapp/domain/entities.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  final VoidCallback onClose;

  const Register({super.key, required this.onClose});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final logger = Logger();

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  List<DropdownMenuEntry> categories = [];
  List<DropdownMenuEntry> locations = [];
  List<DropdownMenuEntry> ddds = [];

  String ddd = "84";
  String preferenceNotification = "email";

  List<String> userPreferenceCategory = ["Obras"];
  String? userLocation;

  bool _isLoading = false;

  List<String> errors = [];

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
    value = value ?? passwordController.text;
    if (value.length < 6) {
      if (!errors.contains("password")) errors.add("password");
    } else {
      errors.remove("password");
    }
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final controller = Provider.of<Registercontroller>(context, listen: true);

    setState(() {
      categories = controller.categories
          .map((category) =>
              DropdownMenuEntry(value: category.id, label: category.category))
          .toList();

      locations = controller.locations
          .map((location) =>
              DropdownMenuEntry(value: location.id, label: location.location))
          .toList();

      ddds = controller.ddds
          .map((ddd) =>
              DropdownMenuEntry(value: ddd.id, label: ddd.ddd.toString()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Registro'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onClose,
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: [
            Form(
                key: formKey,
                child: SizedBox(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'Saiba Tudo',
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
                          'Receba apenas o necessário!',
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
                                spacing: 40,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Selecione as categorias:"),
                                      for (DropdownMenuEntry<dynamic> category
                                          in categories)
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: userPreferenceCategory
                                                  .contains(category.label),
                                              onChanged: (value) {
                                                setState(() {
                                                  validateCategory(
                                                      value == true, category);
                                                });
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 20,
                                    children: [
                                      DropdownMenu(
                                        label: userLocation == null
                                            ? const Text("Bairro")
                                            : Text(userLocation!),
                                        dropdownMenuEntries: locations,
                                        initialSelection: userLocation,
                                        width: 195,
                                        onSelected: (value) {
                                          setState(() {
                                            userLocation =
                                                locations[value - 1].label;
                                          });
                                        },
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
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
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "Selecione o meio\nde notificação:"),
                                          Row(
                                            children: [
                                              Checkbox(
                                                  value:
                                                      preferenceNotification ==
                                                          "email",
                                                  semanticLabel: "Email",
                                                  onChanged: (value) {
                                                    setState(() {
                                                      preferenceNotification =
                                                          value == true
                                                              ? "email"
                                                              : "whatsapp";
                                                    });
                                                  }),
                                              Text("Email"),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Row(
                                            children: [
                                              Checkbox(
                                                  value:
                                                      preferenceNotification ==
                                                          "whatsapp",
                                                  semanticLabel: "Whatsapp",
                                                  onChanged: (value) {
                                                    setState(() {
                                                      preferenceNotification =
                                                          value == true
                                                              ? "whatsapp"
                                                              : "email";
                                                    });
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
                                      if (isFocused &&
                                          !errors.contains("name")) {
                                        return Text(
                                            "$currentLength/$maxLength");
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
                                      setState(() {
                                        value = value.replaceAll(
                                            RegExp(r'\s+'), ' ');

                                        validateName(value);

                                        nameController.value = TextEditingValue(
                                          text: value,
                                        );
                                      });
                                    },
                                  ),
                                  if (errors.contains("name"))
                                    Text(
                                      "Digite ao menos 3 caracteres",
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
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
                                      if (isFocused &&
                                          !errors.contains("email")) {
                                        return Text(
                                            "$currentLength/$maxLength");
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
                                      setState(() {
                                        value = value.replaceAll(" ", "");

                                        validateEmail(value);

                                        emailController.value =
                                            TextEditingValue(
                                          text: value,
                                        );
                                      });
                                    },
                                  ),
                                  if (errors.contains("email"))
                                    Text(
                                      "Digite um email válido\nEx: email@gmail.com",
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
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
                                          setState(() {
                                            ddd = ddds[value - 1].label;
                                          });
                                        },
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
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
                                            whatsappController.value =
                                                TextEditingValue(
                                              text: validateWhatsapp(value),
                                            );
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
                                  if (errors.contains("whatsapp"))
                                    Text(
                                      "Digite um número válido",
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
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
                                      if (isFocused &&
                                          !errors.contains("password")) {
                                        return Text(
                                            "$currentLength/$maxLength");
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
                                      setState(() {
                                        validatePassword(value);
                                      });
                                    },
                                  ),
                                  if (errors.contains("password"))
                                    Text(
                                      "Digite ao menos 6 caracteres",
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
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
                                  onPressed: () {
                                    setState(() {
                                      try {
                                        validatePreferenceCategory();
                                        validateName(null);
                                        validateEmail(null);
                                        validateWhatsapp(null);
                                        validatePassword(null);
                                        if (errors.isEmpty) {
                                          _isLoading = true;

                                          logger.i(
                                              "RegisterPage: Formulário válido");

                                          Registercontroller()
                                              .registerUser(User(
                                            name: formatName().trim(),
                                            email: emailController.text,
                                            whatsapp: whatsappController.text
                                                .replaceAll("-", ""),
                                            password: passwordController.text,
                                            categories: userPreferenceCategory,
                                            location: userLocation,
                                            preferenceNotification:
                                                preferenceNotification,
                                          ));

                                          widget.onClose();
                                        } else {
                                          logger.e(
                                              "RegisterPage: Formulário inválido");
                                        }
                                      } catch (e) {
                                        logger.e(
                                            "RegisterPage: Erro no cadastro => $e");
                                        errors.add("form");
                                      }
                                      _isLoading = false;
                                    });
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
                                          'Cadastrar',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                        ),
                                ),
                              ),
                              if (errors.contains("form"))
                                Text(
                                  "Erro cadastrando dados, por favor entre em contato com a equipe.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          )),
                    ],
                  ),
                ))
          ],
        ));
  }
}
