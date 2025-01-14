import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:meavisapp/controller/controller.dart';
import 'package:meavisapp/domain/entities.dart';

class Admin extends StatefulWidget {
  final AdminController adminController;
  final VoidCallback onLogout;
  final UserController userController;
  final UserLogged? userLogged;

  const Admin(
      {super.key,
      required this.adminController,
      required this.onLogout,
      required this.userController,
      this.userLogged});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final Logger logger = Logger();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController textController = TextEditingController();

  List<DropdownMenuEntry> categories = [];
  List<DropdownMenuEntry> locations = [];
  List<DropdownMenuEntry> ddds = [];

  String ddd = "84";

  bool _isLoading = false;

  List<String> notificationCategory = ["Obras"];
  String? notificationLocation;

  int countSend = 0;
  List<String> names = [];

  String? successMessage;
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
    if (notificationCategory.isEmpty) {
      errors.add("category");
    } else {
      errors.remove("category");
    }
  }

  void validateCategory(bool value, DropdownMenuEntry<dynamic> category) {
    if (value) {
      notificationCategory.add(category.label);
    } else {
      notificationCategory.remove(category.label);
    }

    validatePreferenceCategory();
  }

  void validateTitle() {
    if (titleController.text.isEmpty) {
      errors.add("title");
    } else {
      errors.remove("title");
    }
  }

  void validateText() {
    if (textController.text.isEmpty) {
      errors.add("text");
    } else {
      errors.remove("text");
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
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
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
          child: Column(
            spacing: 20,
            children: [
              SizedBox(
                height: 100,
              ),
              Text(
                'Nova Notificação',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 48,
                ),
              ),
              Text("Cadastre uma nova informação para os usuários",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  )),
              Row(
                spacing: 40,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Selecione as categorias:"),
                      for (DropdownMenuEntry<dynamic> category in categories)
                        Row(
                          children: [
                            Checkbox(
                              value:
                                  notificationCategory.contains(category.label),
                              onChanged: (value) {
                                setState(() {
                                  validateCategory(value == true, category);
                                });
                              },
                            ),
                            Text(category.label),
                          ],
                        ),
                      if (errors.contains("category") &&
                          notificationCategory.isEmpty)
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 20,
                    children: [
                      DropdownMenu(
                        label: notificationLocation == null
                            ? const Text("Bairro")
                            : Text(notificationLocation!),
                        dropdownMenuEntries: locations,
                        initialSelection: notificationLocation,
                        width: 195,
                        onSelected: (value) {
                          setState(() {
                            notificationLocation = locations[value - 1].label;
                          });
                        },
                        inputDecorationTheme: InputDecorationTheme(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        menuStyle: MenuStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).colorScheme.surface),
                          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                              EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5)),
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
                    controller: titleController,
                    maxLength: 100,
                    buildCounter: (BuildContext context,
                        {required int currentLength,
                        required int? maxLength,
                        required bool isFocused}) {
                      if (isFocused && !errors.contains("Título")) {
                        return Text("$currentLength/$maxLength");
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Título",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        titleController.value = TextEditingValue(
                          text: value,
                        );
                      });
                    },
                  ),
                  if (errors.contains("title"))
                    Text(
                      "Digite um título para a notificação",
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
                    controller: textController,
                    maxLength: 500,
                    minLines: 1,
                    maxLines: 10,
                    buildCounter: (BuildContext context,
                        {required int currentLength,
                        required int? maxLength,
                        required bool isFocused}) {
                      if (isFocused && !errors.contains("Texto")) {
                        return Text("$currentLength/$maxLength");
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Texto",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                  if (errors.contains("text"))
                    Text(
                      "Digite um texto para a notificação",
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
                                color: Theme.of(context).colorScheme.primary,
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
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  setState(() {
                                    errors.remove("form");
                                    successMessage = null;
                                  });
                                  validatePreferenceCategory();
                                  validateTitle();
                                  validateText();

                                  if (errors.isEmpty) {
                                    loading(true);

                                    logger.i("AdminPage: Formulário válido");

                                    String message;
                                    int code;

                                    (message, code) = await widget
                                        .adminController
                                        .sendNotification(
                                            notificationCategory,
                                            notificationLocation,
                                            titleController.text,
                                            textController.text);

                                    if (code == 204) {
                                      setState(() {
                                        successMessage =
                                            "Notificação enviada com sucesso!";
                                      });
                                    }

                                    if (code == 500) {
                                      registerErrorF(message);
                                    }
                                  } else {
                                    logger.e(
                                        "AdminPage: Formulário inválido => $errors");

                                    registerErrorF(
                                        "Preencha todos os campos corretamente");
                                  }
                                } catch (e) {
                                  logger.e("AdminPage: Erro no envio => $e");
                                  registerErrorF(
                                      "Erro enviando notificação, por favor entre em contato com a equipe");
                                }
                                loading(false);
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
                                      'Enviar',
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
                          "Erro enviando notificação, por favor entre em contato com a equipe",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ))
      ],
    ));
  }
}
