import 'package:meavisa/domain/interfaces.dart';

class Notification implements INotification {
  @override
  final String title;
  @override
  final String text;
  @override
  final String date;
  @override
  final String time;
  @override
  final String? location;
  @override
  final List<String> categories;
  @override
  final List<String> users;

  Notification({
    required this.title,
    required this.text,
    required this.date,
    required this.time,
    required this.categories,
    required this.users,
    this.location,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'text': text,
      'date': date,
      'time': time,
      'location': location,
      'categories': categories,
      'users': users,
    };
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      title: json['title'],
      text: json['text'],
      date: json['date'],
      time: json['time'],
      location: json['location'],
      categories: List<String>.from(json['categories']),
      users: List<String>.from(json['users']),
    );
  }
}

class UserNotification implements IUserNotification {
  @override
  final String name;
  @override
  final String preferenceNotification;
  @override
  final String? email;
  @override
  final String? whatsapp;

  UserNotification({
    required this.name,
    required this.preferenceNotification,
    this.email,
    this.whatsapp,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      name: json['name'],
      preferenceNotification: json['preferenceNotification'],
      email: json['email'],
      whatsapp: json['whatsapp'],
    );
  }
}

class User implements IUser {
  @override
  String? id;
  @override
  final String name;
  @override
  String password;
  @override
  final List<String> categories;
  @override
  final String preferenceNotification;
  @override
  final String? location;
  @override
  final String? email;
  @override
  final String? whatsapp;
  @override
  bool? isAdmin;

  User(
      {required this.name,
      required this.password,
      required this.categories,
      required this.preferenceNotification,
      this.location,
      this.email,
      this.whatsapp,
      this.id,
      this.isAdmin});

  void attId(String id) {
    this.id = id;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'password': password,
      'categories': categories,
      'preferenceNotification': preferenceNotification,
      'location': location,
      'email': email,
      'whatsapp': whatsapp,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['_id'].toHexString().toString(),
        name: json['name'],
        password: json['password'],
        categories: List<String>.from(json['categories']),
        preferenceNotification: json['preferenceNotification'],
        location: json['location'],
        email: json['email'],
        whatsapp: json['whatsapp'],
        isAdmin: json['isAdmin'] == true);
  }
}

class UserLogged implements IUserLogged {
  @override
  final String id;
  @override
  final String name;
  @override
  String? email;
  @override
  String? whatsapp;
  @override
  final String? location;
  @override
  final List<String> categories;
  @override
  final String preferenceNotification;
  @override
  bool isAdmin;

  UserLogged(
      {required this.id,
      required this.name,
      this.email,
      this.whatsapp,
      this.location,
      required this.categories,
      required this.preferenceNotification,
      required this.isAdmin});
}

class UserLocation implements ILocation {
  @override
  final int id;
  @override
  final String location;

  UserLocation({required this.id, required this.location});
}

class DDD implements Iddd {
  @override
  final int id;
  @override
  final String ddd;

  DDD({required this.id, required this.ddd});
}

class Category implements ICategory {
  @override
  final int id;
  @override
  final String category;

  Category({required this.id, required this.category});
}
