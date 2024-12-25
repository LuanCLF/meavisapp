import 'package:logger/logger.dart';
import 'package:meavisapp/domain/entities.dart';
import 'package:meavisapp/domain/interfaces.dart';
import 'package:meavisapp/repository/repository.dart';
import 'package:flutter/material.dart';

class Registercontroller extends ChangeNotifier {
  final _logger = Logger();

  final UserRepository _userRepository = UserRepository();
  final LocationRepository _locationRepository = LocationRepository();
  final DDDRepository _dddRepository = DDDRepository();
  final CategorieRepository _categorieRepository = CategorieRepository();

  List<ICategory> categories = [];
  List<ILocation> locations = [];
  List<Iddd> ddds = [];

  Registercontroller() {
    getCategories();
    getLocations();
    getDDDs();
  }

  Future<void> registerUser(User user) async {
    try {
      await _userRepository.registerUser(user);
      notifyListeners();

      _logger.i("Registercontroller-registerUser: Usuário cadastrado",
          time: DateTime.now());
    } catch (e) {
      _logger.e(
        "Registercontroller-registerUser: Erro registrando usuário => $e",
        time: DateTime.now(),
      );
      rethrow;
    }
  }

  void getCategories() async {
    categories = await _categorieRepository.getCategories();
    notifyListeners();
  }

  void getLocations() async {
    locations = await _locationRepository.getLocations();
    notifyListeners();
  }

  void getDDDs() async {
    ddds = await _dddRepository.getDDDs();
    notifyListeners();
  }
}
