import 'package:logger/logger.dart';
import 'package:meavisapp/domain/entities.dart';
import 'package:meavisapp/domain/interfaces.dart';
import 'package:meavisapp/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminController extends ChangeNotifier {
  int totalUsers = 0;
  final AdminRepository _adminRepository = AdminRepository();
  final _logger = Logger();

  Future<(String, int)> sendNotification(List<String> categories,
      String? location, String subject, String body) async {
    try {
      List<UserNotification> users = await _findUsers(categories, location);
      await _adminRepository.sendNotification(
          users, subject, body, categories, location);

      _logger.i(
          "AdminController-sendNotification: Notificação enviada => Quantidade de usuários cadastrados para essa notificação: ${users.length}",
          time: DateTime.now());

      return ("Notificação enviada", 204);
    } catch (e) {
      _logger.e(
        "AdminController-sendNotification: Erro enviando notificação => $e",
        time: DateTime.now(),
      );
      return ("Erro enviando notificação", 500);
    }
  }

  Future<List<UserNotification>> _findUsers(
      List<String> categories, String? location) async {
    try {
      List<UserNotification> users =
          await _adminRepository.findUsers(categories, location);
      _logger.i("AdminController-findUsers: Usuários encontrados",
          time: DateTime.now());

      return users;
    } catch (e) {
      _logger.e(
        "AdminController-findUsers: Erro encontrando usuários => $e",
        time: DateTime.now(),
      );
    }
    return [];
  }
}

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

  Future<(String, int)> registerUser(User user) async {
    try {
      (bool, bool) userExists =
          await _userRepository.checkIfUserExists(user.email, user.whatsapp);
      if (userExists.$1 && userExists.$2) {
        return ("Email e Whatsapp já cadastrados", 409);
      } else if (userExists.$1) {
        return ("Email já cadastrado", 409);
      } else if (userExists.$2) {
        return ("Whatsapp já cadastrado", 409);
      }

      await _userRepository.registerUser(user);
      userLogged = UserLogged(
        id: "",
        name: user.name,
        categories: user.categories,
        preferenceNotification: user.preferenceNotification,
        email: user.email,
        whatsapp: user.whatsapp,
        location: user.location,
        isAdmin: false,
      );

      notifyListeners();

      _logger.i("UserController-registerUser: Usuário cadastrado",
          time: DateTime.now());
      return ("Usuário cadastrado", 201);
    } catch (e) {
      _logger.e(
        "UserController-registerUser: Erro registrando usuário => $e",
        time: DateTime.now(),
      );
      return ("Erro registrando usuário", 500);
    }
  }

  Future<(String, int)> updateUser(User user) async {
    try {
      (bool, bool) userExists = await _userRepository
          .checkIfUserExistsForUpdate(user.email, user.whatsapp, user.id!);
      if (userExists.$1 && userExists.$2) {
        return ("Email e Whatsapp já cadastrados", 409);
      } else if (userExists.$1) {
        return ("Email já cadastrado", 409);
      } else if (userExists.$2) {
        return ("Whatsapp já cadastrado", 409);
      }
      await _userRepository.updateUser(user);
      await _saveInPreferences(user);
      userLogged = UserLogged(
          id: user.id!,
          name: user.name,
          categories: user.categories,
          preferenceNotification: user.preferenceNotification,
          email: user.email,
          whatsapp: user.whatsapp,
          location: user.location,
          isAdmin: user.isAdmin == true);
      notifyListeners();
      _logger.i("UserController-updateUser: Usuário atualizado",
          time: DateTime.now());

      return ("Usuário atualizado", 204);
    } catch (e) {
      _logger.e(
        "UserController-updateUser: Erro atualizando usuário => $e",
        time: DateTime.now(),
      );
      return ("Erro atualizando usuário", 500);
    }
  }

  Future<(String, int)> login(
      String loginId, String loginMethod, String password) async {
    try {
      User? user = loginMethod == "email"
          ? await _userRepository.findUser(loginId, null)
          : await _userRepository.findUser(null, loginId);

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
            categories: prefs
                .getString("categories")!
                .replaceAll("[", "")
                .replaceAll("]", "")
                .replaceAll(" ", "")
                .split(","),
            preferenceNotification: prefs.getString("preferenceNotification")!,
            email: prefs.getString("email"),
            whatsapp: prefs.getString("whatsapp"),
            location: prefs.getString("location"),
            isAdmin: prefs.getBool("isAdmin") == true);
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
    prefs.remove("isAdmin");

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

    prefs.setBool("isAdmin", user.isAdmin!);

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
