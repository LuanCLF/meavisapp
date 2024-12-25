import 'package:meavisapp/domain/interfaces.dart';

class User implements IUser {
  @override
  int? id;
  @override
  final String name;
  @override
  final String password;
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
  });

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
