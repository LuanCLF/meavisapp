import 'package:flutter/material.dart';
import 'package:meavisapp/controller/controller.dart';
import 'package:meavisapp/domain/entities.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.userController.logout();
                  widget.onLogout();
                });
              },
              child: Text("Sair"))),
    );
  }
}
