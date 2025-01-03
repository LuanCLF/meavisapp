import 'package:logger/logger.dart';
import 'package:meavisapp/domain/entities.dart';
import 'package:meavisapp/domain/interfaces.dart';
import 'package:meavisapp/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends ChangeNotifier {
  final _logger = Logger();

  final UserRepository _userRepository = UserRepository();
  final LocationRepository _locationRepository = LocationRepository();
  final DDDRepository _dddRepository = DDDRepository();
  final CategorieRepository _categorieRepository = CategorieRepository();

  bool isLogged = false;
  UserLogged? userLogged;

  List<ICategory> categories = [];
  List<ILocation> locations = [];
  List<Iddd> ddds = [];

  UserController();

  Future<void> registerUser(User user) async {
    try {
      await _userRepository.registerUser(user);
      userLogged = UserLogged(
        id: "",
        name: user.name,
        categories: user.categories,
        preferenceNotification: user.preferenceNotification,
        email: user.email,
        whatsapp: user.whatsapp,
        location: user.location,
      );

      notifyListeners();

      _logger.i("UserController-registerUser: Usuário cadastrado",
          time: DateTime.now());
    } catch (e) {
      _logger.e(
        "UserController-registerUser: Erro registrando usuário => $e",
        time: DateTime.now(),
      );
    }
  }

  Future<(String, int)> login(
      String loginId, String loginMethod, String password) async {
    try {
      User? user = loginMethod == "email"
          ? await _userRepository.findUserByEmail(loginId)
          : await _userRepository.findUserByWhatsapp(loginId);

      if (user == null) {
        return ("Usuário não encontrado", 404);
      }
      if (user.password != password) {
        return ("Senha incorreta", 401);
      }

      await _saveInPreferences(user);
      _logger.i("UserController-login: Usuário logado", time: DateTime.now());

      isLogged = true;
      return ("Usuário logado", 200);
    } catch (e) {
      _logger.e(
        "UserController-findUserByEmail: Erro buscando usuário => $e",
        time: DateTime.now(),
      );

      isLogged = false;
      return ("Erro buscando usuário", 500);
    } finally {
      notifyListeners();
    }
  }

  Future<void> getLoggedUser() async {
    SharedPreferences prefs;

    try {
      prefs = await SharedPreferences.getInstance();

      if (prefs.getString("id") != null) {
        userLogged = UserLogged(
          id: prefs.getString("id")!,
          name: prefs.getString("name")!,
          categories: prefs.getString("categories")!.split(","),
          preferenceNotification: prefs.getString("preferenceNotification")!,
          email: prefs.getString("email"),
          whatsapp: prefs.getString("whatsapp"),
          location: prefs.getString("location"),
        );
        isLogged = true;
        _logger.i("UserController-getLoggedUser: Usuário logado");
      } else {
        isLogged = false;
        _logger.i("UserController-getLoggedUser: Usuário não está logado");
      }
    } catch (e) {
      isLogged = false;
      _logger.e(
        "UserController-getLoggedUser: Erro buscando usuário logado => $e",
        time: DateTime.now(),
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("id");
    prefs.remove("name");
    prefs.remove("categories");
    prefs.remove("preferenceNotification");
    prefs.remove("email");
    prefs.remove("whatsapp");
    prefs.remove("location");

    isLogged = false;
    userLogged = null;
    notifyListeners();
  }

  Future<void> _saveInPreferences(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("id", user.id!);
    prefs.setString("name", user.name);
    prefs.setString("categories", user.categories.toString());
    prefs.setString("preferenceNotification", user.preferenceNotification);
    if (user.email != null) {
      prefs.setString("email", user.email!);
    }
    if (user.whatsapp != null) {
      prefs.setString("whatsapp", user.whatsapp!);
    }
    if (user.location != null) {
      prefs.setString("location", user.location!);
    }
  }

  Future<void> getCategories() async {
    categories = await _categorieRepository.getCategories();
    notifyListeners();
  }

  Future<void> getLocations() async {
    locations = await _locationRepository.getLocations();
    notifyListeners();
  }

  Future<void> getDDDs() async {
    ddds = await _dddRepository.getDDDs();
    notifyListeners();
  }
}
