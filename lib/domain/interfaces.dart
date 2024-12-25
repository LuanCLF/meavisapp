abstract class IUser {
  int? get id;
  String get name;
  String get password;
  List<String> get categories;
  String get preferenceNotification;
  String? get location;
  String? get email;
  String? get whatsapp;
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
