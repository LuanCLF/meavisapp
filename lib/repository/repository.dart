import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:meavisapp/domain/entities.dart';
import 'package:meavisapp/domain/interfaces.dart';
import 'package:meavisapp/infra/database.dart';

class NotificationRepository {
  final logger = Logger();

  Future<void> _init() async {
    try {
      await Database.connect();
      logger.i("AdminRepository-init: Conexão com banco de dados aberta",
          time: DateTime.now());
    } catch (e) {
      logger.e("AdminRepository-init: Erro conectando com banco de dados => $e",
          time: DateTime.now());
    }
  }

  Future<void> _close() async {
    try {
      await Database.close();
      logger.i("AdminRepository-close: Conexão com banco de dados fechada",
          time: DateTime.now());
    } catch (e) {
      logger.e(
          "AdminRepository-close: Erro fechando conexão com banco de dados => $e",
          time: DateTime.now());
    }
  }

  Future<(List<Notification>, int)> getNotifications(
      List<String> categories, String? location, bool all, int page) async {
    try {
      await _init();

      List<Notification> notifications;
      int pages;
      (
        notifications,
        pages,
      ) = await Database.getNotifications(categories, location, all, page);

      logger.i("AdminRepository-getNotifications: Notificações encontradas",
          time: DateTime.now());

      await _close();
      return (notifications, pages);
    } catch (e) {
      logger.e(
        "AdminRepository-getNotifications: Erro buscando notificações => $e",
        time: DateTime.now(),
      );

      await _close();
      throw "AdminRepository-getNotifications: Erro buscando notificações => $e";
    }
  }
}

class AdminRepository {
  final logger = Logger();
  final htppAdmin = HttpClient();

  Future<void> _init() async {
    try {
      await Database.connect();
      logger.i("AdminRepository-init: Conexão com banco de dados aberta",
          time: DateTime.now());
    } catch (e) {
      logger.e("AdminRepository-init: Erro conectando com banco de dados => $e",
          time: DateTime.now());
    }
  }

  Future<void> _close() async {
    try {
      await Database.close();
      logger.i("AdminRepository-close: Conexão com banco de dados fechada",
          time: DateTime.now());
    } catch (e) {
      logger.e(
          "AdminRepository-close: Erro fechando conexão com banco de dados => $e",
          time: DateTime.now());
    }
  }

  Future<void> _registerNotification(Notification notification) async {
    try {
      await _init();

      await Database.insertNotification(notification);
      logger.i("AdminRepository-registerNotification: Notificação cadastrada",
          time: DateTime.now());

      await _close();
    } catch (e) {
      logger.e(
        "AdminRepository-registerNotification: Erro registrando notificação => $e",
        time: DateTime.now(),
      );

      await _close();
      throw "AdminRepository-registerNotification: Erro registrando notificação => $e";
    }
  }

  Future<List<UserNotification>> findUsers(
      List<String> categories, String? location) async {
    try {
      await _init();
      List<UserNotification> users =
          await Database.findUsers(categories, location);
      logger.i("AdminRepository-findUsers: Usuários encontrados",
          time: DateTime.now());

      await _close();
      return users;
    } catch (e) {
      logger.e(
        "AdminRepository-findUsers: Erro encontrando usuários => $e",
        time: DateTime.now(),
      );

      await _close();
      throw "AdminRepository-findUsers: Erro encontrando usuários => $e";
    }
  }

  Future<void> sendNotification(List<UserNotification> users, String subject,
      String body, List<String> categories, String? location) async {
    try {
      List<String> userNames = [];
      List<String> emails = [];
      List<String> phones = [];

      for (UserNotification user in users) {
        userNames.add(user.name);
        if (user.email != null && user.email!.isNotEmpty) {
          emails.add(user.email!);
        }
        if (user.whatsapp != null && user.whatsapp!.isNotEmpty) {
          phones.add(user.whatsapp!);
        }
      }

      DateTime now = DateTime.now();

      await _registerNotification(Notification(
        title: subject,
        text: body,
        date:
            '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
        time: now.toString().substring(11, 16),
        location: location,
        categories: categories,
        users: userNames.isNotEmpty ? userNames : [],
      ));

      if (emails.isNotEmpty) await _sendEmail(emails, subject, body);

      if (phones.isNotEmpty) await _sendWhatsApp(phones, body);

      logger.i("AdminRepository-sendNotification: Notificação enviada",
          time: DateTime.now());
    } catch (e) {
      logger.e(
        "AdminRepository-sendNotification: Erro enviando notificação => $e",
        time: DateTime.now(),
      );

      throw "AdminRepository-sendNotification: Erro enviando notificação => $e";
    }
  }

  Future<void> _sendEmail(
      List<String> emails, String subject, String body) async {
    String email = dotenv.env['EMAIL']!;
    String name = dotenv.env['NAME']!;

    String smtphost = dotenv.env['SMTP_HOST']!;
    String smtpport = dotenv.env['SMTP_PORT']!;
    String smtpusername = dotenv.env['SMTP_USERNAME']!;
    String smptkey = dotenv.env['SMTP_KEY']!;
    String smtpcertificate = dotenv.env['SMTP_CERTIFICATE']!;

    final smtpServer = SmtpServer(smtphost,
        port: int.tryParse(smtpport)!,
        username: smtpusername,
        password: smptkey,
        ignoreBadCertificate: smtpcertificate == "true");
    final message = Message()
      ..from = Address(email, name)
      ..subject = subject
      ..recipients = emails
      ..text = body;

    try {
      final sendReport = await send(message, smtpServer);
      logger.i(
          'AdminRepository-_sendEmail: Relatório do envio de mensagens: $sendReport');
    } on MailerException catch (e) {
      logger.i('AdminRepository-_sendEmail: Erro enviando email => $e');
      throw 'AdminRepository-_sendEmail: Erro enviando email => $e';
    }
  }

  Future<void> _sendWhatsApp(List<String> phones, String body) async {
    for (String phone in phones) {
      try {
        final uri = Uri.parse(
            "https://hook.us2.make.com/drc4kg7u5w73kqc9ja6hkwjcwyjksmuy");
        final request = await htppAdmin.postUrl(uri);
        request.headers.set('Content-Type', 'application/json');
        request.add(utf8.encode(jsonEncode({
          'to': '55${phone.replaceAll('-', '').trim()}',
          'message': body,
        })));

        await request.close();

        logger.i(
            'AdminRepository-_sendWhatsApp: Whatsapp enviado - $phone - ${DateTime.now()}');
      } catch (e) {
        logger.e('AdminRepository-_sendWhatsApp: Erro enviando whatsapp => $e');
      }
    }
  }
}

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

  Future<void> _close() async {
    try {
      await Database.close();
      logger.i("UserRepository-close: Conexão com banco de dados fechada",
          time: DateTime.now());
    } catch (e) {
      logger.e(
          "UserRepository-close: Erro fechando conexão com banco de dados => $e",
          time: DateTime.now());
    }
  }

  Future<bool> registerUser(User user) async {
    try {
      await _init();

      await Database.insertUser(user);
      logger.i("UserRepository-registerUser: Usuário cadastrado",
          time: DateTime.now());

      await _close();
      return true;
    } catch (e) {
      logger.e(
        "UserRepository-registerUser: Erro registrando usuário => $e",
        time: DateTime.now(),
      );

      await _close();
      throw "UserRepository-registerUser: Erro registrando usuário => $e";
    }
  }

  Future updateUser(User user) async {
    try {
      await _init();
      await Database.updateUser(user);
      logger.i("UserRepository-updateUser: Usuário atualizado",
          time: DateTime.now());

      await _close();
    } catch (e) {
      logger.e(
        "UserRepository-updateUser: Erro atualizando usuário => $e",
        time: DateTime.now(),
      );

      await _close();
      throw "UserRepository-updateUser: Erro atualizando usuário => $e";
    }
  }

  Future<(bool, bool)> checkIfUserExists(
      String? email, String? whatsapp) async {
    try {
      await _init();
      (bool, bool) userExists =
          await Database.checkIfUserExists(email, whatsapp);

      logger.i(
          "UserRepository-checkIfUserExists: Usuário existe => $userExists",
          time: DateTime.now());

      await _close();
      return userExists;
    } catch (e) {
      logger.e(
        "UserRepository-checkIfUserExists: Erro buscando usuário => $e",
        time: DateTime.now(),
      );

      await _close();
      throw "UserRepository-checkIfUserExists: Erro buscando usuário => $e";
    }
  }

  Future<(bool, bool)> checkIfUserExistsForUpdate(
      String? email, String? whatsapp, String id) async {
    try {
      await _init();
      (bool, bool) userExists =
          await Database.checkIfUserExistsForUpdate(email, whatsapp, id);

      logger.i(
          "UserRepository-checkIfUserExistsForUpdate: Usuário existe => $userExists",
          time: DateTime.now());

      await _close();
      return userExists;
    } catch (e) {
      logger.e(
        "UserRepository-checkIfUserExistsForUpdate: Erro buscando usuário => $e",
        time: DateTime.now(),
      );

      await _close();
      throw "UserRepository-checkIfUserExistsForUpdate: Erro buscando usuário => $e";
    }
  }

  Future<User?> findUser(String? email, String? whatsapp) async {
    try {
      await _init();
      User? user = email != null
          ? await Database.findUser(email, null)
          : await Database.findUser(null, whatsapp);

      logger.i("UserRepository-findUserByEmail: Usuário encontrado",
          time: DateTime.now());

      await _close();
      return user;
    } catch (e) {
      logger.e(
        "UserRepository-findUserByEmail: Erro buscando usuário => $e",
        time: DateTime.now(),
      );

      await _close();
      throw "UserRepository-findUserByEmail: Erro buscando usuário => $e";
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
      UserLocation(id: 1, location: "Sítio Canto"),
      UserLocation(id: 2, location: "Cohab"),
      UserLocation(id: 3, location: "Jacu"),
      UserLocation(id: 4, location: "Centro"),
      UserLocation(id: 5, location: "Umarizeira"),
      UserLocation(id: 6, location: "Canto Bonito"),
      UserLocation(id: 7, location: "Sítio Frade"),
      UserLocation(id: 8, location: "Lagoa Nova"),
      UserLocation(id: 9, location: "Planalto"),
      UserLocation(id: 10, location: "Jocellyn Villar"),
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
