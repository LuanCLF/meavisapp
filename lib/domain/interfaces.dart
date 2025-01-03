abstract class IUser {
  String? get id;
  String get name;
  String get password;
  List<String> get categories;
  String get preferenceNotification;
  String? get location;
  String? get email;
  String? get whatsapp;

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
