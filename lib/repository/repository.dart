import 'package:logger/logger.dart';
import 'package:meavisapp/domain/entities.dart';
import 'package:meavisapp/domain/interfaces.dart';
import 'package:meavisapp/infra/database.dart';

class UserRepository {
  final logger = Logger();

  Future<void> _init() async {
    try {
      await Database.connect();
      logger.i("UserRepository-init: Conexão com banco de dados aberta",
          time: DateTime.now());
    } catch (e) {
      logger.e("UserRepository-init: Erro conectando com banco de dados => $e",
          time: DateTime.now());
    }
  }

  Future registerUser(User user) async {
    try {
      await _init();
      await Database.insertUser(user);
      logger.i("UserRepository-registerUser: Usuário cadastrado",
          time: DateTime.now());
    } catch (e) {
      logger.e(
        "UserRepository-registerUser: Erro registrando usuário => $e",
        time: DateTime.now(),
      );
      throw "UserRepository-registerUser: Erro registrando usuário => $e";
    }
  }

  Future<User?> findUserByEmail(String email) async {
    try {
      await _init();
      var user = await Database.findUserByEmail(email);
      logger.i("UserRepository-findUserByEmail: Usuário encontrado",
          time: DateTime.now());
      return user;
    } catch (e) {
      logger.e(
        "UserRepository-findUserByEmail: Erro buscando usuário => $e",
        time: DateTime.now(),
      );
      throw "UserRepository-findUserByEmail: Erro buscando usuário => $e";
    }
  }

  Future<User?> findUserByWhatsapp(String whatsapp) async {
    try {
      await _init();
      var user = await Database.findUserByWhatsapp(whatsapp);
      logger.i("UserRepository-findUserByWhatsapp: Usuário encontrado",
          time: DateTime.now());
      return user;
    } catch (e) {
      logger.e(
        "UserRepository-findUserByWhatsapp: Erro buscando usuário => $e",
        time: DateTime.now(),
      );
      throw "UserRepository-findUserByWhatsapp: Erro buscando usuário => $e";
    }
  }
}

class CategorieRepository {
  Future<List<ICategory>> getCategories() async {
    List<ICategory> categories = [
      Category(id: 1, category: "Obras"),
      Category(id: 2, category: "Água/energia"),
      Category(id: 3, category: "Eventos"),
      Category(id: 4, category: "Concursos"),
      Category(id: 5, category: "Atendimentos"),
      Category(id: 6, category: "Vacinas"),
      Category(id: 7, category: "Campanhas"),
    ];
    return categories;
  }
}

class LocationRepository {
  Future<List<ILocation>> getLocations() async {
    List<ILocation> locations = [
      Location(id: 1, location: "Sítio Canto"),
      Location(id: 2, location: "Cohab"),
      Location(id: 3, location: "Jacu"),
      Location(id: 4, location: "Centro"),
      Location(id: 5, location: "Umarizeira"),
      Location(id: 6, location: "Canto Bonito"),
      Location(id: 7, location: "Sítio Frade"),
      Location(id: 8, location: "Lagoa Nova"),
      Location(id: 9, location: "Planalto"),
      Location(id: 10, location: "Jocellyn Villar"),
    ];
    return locations;
  }
}

class DDDRepository {
  Future<List<Iddd>> getDDDs() async {
    List<Iddd> ddds = [
      DDD(id: 1, ddd: "11"),
      DDD(id: 2, ddd: "12"),
      DDD(id: 3, ddd: "13"),
      DDD(id: 4, ddd: "14"),
      DDD(id: 5, ddd: "15"),
      DDD(id: 6, ddd: "16"),
      DDD(id: 7, ddd: "17"),
      DDD(id: 8, ddd: "18"),
      DDD(id: 9, ddd: "19"),
      DDD(id: 10, ddd: "21"),
      DDD(id: 11, ddd: "22"),
      DDD(id: 12, ddd: "24"),
      DDD(id: 13, ddd: "27"),
      DDD(id: 14, ddd: "28"),
      DDD(id: 15, ddd: "31"),
      DDD(id: 16, ddd: "32"),
      DDD(id: 17, ddd: "33"),
      DDD(id: 18, ddd: "34"),
      DDD(id: 19, ddd: "35"),
      DDD(id: 20, ddd: "37"),
      DDD(id: 21, ddd: "38"),
      DDD(id: 22, ddd: "41"),
      DDD(id: 23, ddd: "42"),
      DDD(id: 24, ddd: "43"),
      DDD(id: 25, ddd: "44"),
      DDD(id: 26, ddd: "45"),
      DDD(id: 27, ddd: "46"),
      DDD(id: 28, ddd: "47"),
      DDD(id: 29, ddd: "48"),
      DDD(id: 30, ddd: "49"),
      DDD(id: 31, ddd: "51"),
      DDD(id: 32, ddd: "53"),
      DDD(id: 33, ddd: "54"),
      DDD(id: 34, ddd: "55"),
      DDD(id: 35, ddd: "61"),
      DDD(id: 36, ddd: "62"),
      DDD(id: 37, ddd: "63"),
      DDD(id: 38, ddd: "64"),
      DDD(id: 39, ddd: "65"),
      DDD(id: 40, ddd: "66"),
      DDD(id: 41, ddd: "67"),
      DDD(id: 42, ddd: "68"),
      DDD(id: 43, ddd: "69"),
      DDD(id: 44, ddd: "71"),
      DDD(id: 45, ddd: "73"),
      DDD(id: 46, ddd: "74"),
      DDD(id: 47, ddd: "75"),
      DDD(id: 48, ddd: "77"),
      DDD(id: 49, ddd: "79"),
      DDD(id: 50, ddd: "81"),
      DDD(id: 51, ddd: "82"),
      DDD(id: 52, ddd: "83"),
      DDD(id: 53, ddd: "84"),
      DDD(id: 54, ddd: "85"),
      DDD(id: 55, ddd: "86"),
      DDD(id: 56, ddd: "87"),
      DDD(id: 57, ddd: "88"),
      DDD(id: 58, ddd: "89"),
      DDD(id: 59, ddd: "91"),
      DDD(id: 60, ddd: "92"),
      DDD(id: 61, ddd: "93"),
      DDD(id: 62, ddd: "94"),
      DDD(id: 63, ddd: "95"),
      DDD(id: 64, ddd: "96"),
      DDD(id: 65, ddd: "97"),
      DDD(id: 66, ddd: "98"),
      DDD(id: 67, ddd: "99"),
    ];
    return ddds;
  }
}
