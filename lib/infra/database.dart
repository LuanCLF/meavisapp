import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:meavisa/domain/entities.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Database {
  static final _logger = Logger();
  static Db? _db;
  static DbCollection? userCollection;
  static DbCollection? notificationCollection;

  static Future<void> connect() async {
    try {
      _db = await Db.create(dotenv.env['MONGO_DB_URI']!);
      _db?.databaseName = 'MEAVISA';
      await _db!.open();

      var status = await _db!.serverStatus();
      Database._logger.i("Database-connect: Status do servidor => $status");
    } catch (e) {
      Database._logger.e('Database-connect: Erro conectando ao MongoDB => $e');
    }
  }

  static Future<(List<Notification>, int)> getNotifications(
      List<String> categories, String? location, bool all, int page) async {
    try {
      if (_db == null || !_db!.isConnected) {
        throw 'Banco de dados não conectado';
      }

      notificationCollection = _db!.collection("notifications");

      if (notificationCollection == null) {
        throw 'Conexão com notificationCollection falhou';
      }

      var query = <String, dynamic>{
        'categories': {'\$in': categories}
      };

      if (location != null) {
        query['location'] = location;
      }

      List<Notification> notifications;
      int pages;

      if (all) {
        notifications = await notificationCollection!
            .modernFind(
              sort: {'date': -1},
              skip: page > 0 ? 10 * page : null,
              limit: 10,
            )
            .toList()
            .then(
                (value) => value.map((e) => Notification.fromJson(e)).toList());

        pages = (await notificationCollection!.count() / 10).ceil();
      } else {
        notifications = await notificationCollection!
            .modernFind(
              filter: query,
              sort: {'date': -1},
              skip: page > 0 ? 10 * page : null,
              limit: 10,
            )
            .toList()
            .then(
                (value) => value.map((e) => Notification.fromJson(e)).toList());

        _logger.i('${await notificationCollection!.count(query)}');
        pages = (await notificationCollection!.count(query) / 10).ceil();
      }

      Database._logger.i("Database: Notificações encontradas");
      return (notifications, pages);
    } catch (e) {
      Database._logger.e("Database: Erro buscando notificações => $e");
      throw 'Database: Erro buscando notificações => $e';
    }
  }

  static Future<void> insertNotification(Notification notification) async {
    try {
      notificationCollection = _db!.collection("notifications");

      if (_db == null || !_db!.isConnected) {
        throw 'Banco de dados não conectado';
      }

      if (notificationCollection == null) {
        throw 'Conexão com userCollection falhou';
      }

      WriteResult result =
          await notificationCollection!.insertOne(notification.toJson());
      Database._logger.i("Database: Notificação cadastrada => $result");
    } catch (e) {
      Database._logger.e("Database: Erro cadastrando notificação => $e");
      throw 'Database: Erro cadastrando notificação => $e';
    }
  }

  static Future<void> insertUser(User user) async {
    try {
      userCollection = _db!.collection("users");

      if (_db == null || !_db!.isConnected) {
        throw 'Banco de dados não conectado';
      }

      if (userCollection == null) {
        throw 'Conexão com userCollection falhou';
      }

      WriteResult result = await userCollection!.insertOne(user.toJson());
      Database._logger.i("Database: Usuário cadastrado => $result");
    } catch (e) {
      Database._logger.e("Database: Erro cadastrando usuário => $e");
      throw 'Database: Erro cadastrando usuário => $e';
    }
  }

  static Future<void> updateUser(User user) async {
    try {
      userCollection = _db!.collection("users");

      if (_db == null || !_db!.isConnected) {
        throw 'Banco de dados não conectado';
      }

      if (userCollection == null) {
        throw 'Conexão com userCollection falhou';
      }
      Map<String, dynamic> result;
      ObjectId id = ObjectId.parse(user.id!);
      if (user.password.isEmpty) {
        var userMap = await userCollection!.findOne({"_id": id});
        user.password = userMap!['password'];
        result = await userCollection!.update(
          {"_id": id},
          user.toJson(),
        );
      } else {
        result = await userCollection!.update(
          {"_id": id},
          user.toJson(),
        );
      }

      Database._logger.i("Database: Usuário atualizado => $result");
    } catch (e) {
      Database._logger.e("Database: Erro atualizando usuário => $e");
      throw 'Database: Erro atualizando usuário => $e';
    }
  }

  static Future<(bool, bool)> checkIfUserExists(
      String? email, String? whatsapp) async {
    try {
      if (_db == null || !_db!.isConnected) {
        throw 'Banco de dados não conectado';
      }

      userCollection = _db!.collection("users");

      if (userCollection == null) {
        throw 'Conexão com userCollection falhou';
      }
      bool userExistsEmail = false;
      bool userExistsWhatsapp = false;

      if (email != null) {
        userExistsEmail =
            await userCollection!.find({"email": email}).isEmpty == false;
      }

      if (whatsapp != null) {
        userExistsWhatsapp =
            await userCollection!.find({"whatsapp": whatsapp}).isEmpty == false;
      }

      Database._logger.i(
          "Database: Usuário existe => Email: $userExistsEmail   Whatsapp: $userExistsWhatsapp");
      return (userExistsEmail, userExistsWhatsapp);
    } catch (e) {
      Database._logger.e("Database: Erro verificando se usuário existe => $e");
      throw 'Database: Erro verificando se usuário existe => $e';
    }
  }

  static Future<(bool, bool)> checkIfUserExistsForUpdate(
      String? email, String? whatsapp, String id) async {
    try {
      if (_db == null || !_db!.isConnected) {
        throw 'Banco de dados não conectado';
      }

      userCollection = _db!.collection("users");

      if (userCollection == null) {
        throw 'Conexão com userCollection falhou';
      }

      bool userExistsEmail = false;
      bool userExistsWhatsapp = false;

      if (email != null) {
        int countEmail = await userCollection!.count({
          "email": email,
          "_id": {"\$ne": ObjectId.parse(id)}
        });
        userExistsEmail = countEmail > 0;
      }

      if (whatsapp != null) {
        int countWhatsapp = await userCollection!.count({
          "whatsapp": whatsapp,
          "_id": {"\$ne": ObjectId.parse(id)}
        });
        userExistsWhatsapp = countWhatsapp > 0;
      }

      Database._logger.i(
          "Database: Usuário existe => Email: $userExistsEmail, Whatsapp: $userExistsWhatsapp");
      return (userExistsEmail, userExistsWhatsapp);
    } catch (e) {
      Database._logger.e("Database: Erro verificando se usuário existe => $e");
      throw 'Database: Erro verificando se usuário existe => $e';
    }
  }

  static Future<User?> findUser(String? email, String? whatsapp) async {
    try {
      userCollection = _db!.collection("users");

      if (_db == null || !_db!.isConnected) {
        throw 'Banco de dados não conectado';
      }

      if (userCollection == null) {
        throw 'Conexão com userCollection falhou';
      }

      Map<String, dynamic>? userMap = email != null
          ? await userCollection!.findOne({"email": email})
          : await userCollection!.findOne({"whatsapp": whatsapp});

      User? user = userMap == null ? null : User.fromJson(userMap);

      Database._logger.i("Database: Usuário encontrado => $user");
      return user;
    } catch (e) {
      Database._logger.e("Database: Erro buscando usuário => $e");
      throw 'Database: Erro buscando usuário => $e';
    }
  }

  static Future<void> close() async {
    try {
      await _db!.close();
      Database._logger.i("Database-close: Conexão com banco de dados fechada");
    } catch (e) {
      Database._logger
          .e("Database-close: Erro fechando conexão com banco de dados => $e");
    }
  }

  static Future<List<UserNotification>> findUsers(
      List<String> categories, String? location) async {
    try {
      userCollection = _db!.collection("users");

      if (_db == null || !_db!.isConnected) {
        throw 'Banco de dados não conectado';
      }

      if (userCollection == null) {
        throw 'Conexão com userCollection falhou';
      }

      var query = <String, dynamic>{
        'categories': {'\$in': categories}
      };

      if (location != null) {
        query['location'] = location;
      }

      List<UserNotification> usersNotifications = await userCollection!
          .find(
            query,
          )
          .toList()
          .then((value) =>
              value.map((e) => UserNotification.fromJson(e)).toList());

      Database._logger.i("Database: Usuários encontrados");
      return usersNotifications;
    } catch (e) {
      Database._logger.e("Database: Erro buscando usuários => $e");
      throw 'Database: Erro buscando usuários => $e';
    }
  }
}
