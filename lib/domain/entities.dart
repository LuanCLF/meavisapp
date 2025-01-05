import 'package:meavisapp/domain/interfaces.dart';

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

  User({
    required this.name,
    required this.password,
    required this.categories,
    required this.preferenceNotification,
    this.location,
    this.email,
    this.whatsapp,
    this.id,
  });

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
    );
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

  UserLogged({
    required this.id,
    required this.name,
    this.email,
    this.whatsapp,
    this.location,
    required this.categories,
    required this.preferenceNotification,
  });
}

class Location implements ILocation {
  @override
  final int id;
  @override
  final String location;

  Location({required this.id, required this.location});
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
