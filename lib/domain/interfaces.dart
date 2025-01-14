abstract class INotification {
  String get title;
  String get text;
  String get date;
  String get time;
  String? get location;
  List<String> get categories;
  List<String> get users;

  Map<String, dynamic> toJson();
}

abstract class IUserNotification {
  String get name;
  String get preferenceNotification;
  String? get email;
  String? get whatsapp;
}

abstract class IUser {
  String? get id;
  String get name;
  String get password;
  List<String> get categories;
  String get preferenceNotification;
  String? get location;
  String? get email;
  String? get whatsapp;
  bool? get isAdmin;

  Map<String, dynamic> toJson();
}

abstract class IUserLogged {
  String get id;
  String get name;
  String? get email;
  String? get whatsapp;
  String? get location;
  List<String> get categories;
  String get preferenceNotification;
  bool get isAdmin;
}

abstract class ILocation {
  int get id;
  String get location;
}

abstract class ICategory {
  int get id;
  String get category;
}

abstract class Iddd {
  int get id;
  String get ddd;
}
