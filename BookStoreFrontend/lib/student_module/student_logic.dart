import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'logged_user.dart';

final _defaultLoggedUser = LoggedUser(
  user: User(
    id: 1,
    name: "name",
    email: "email",
    emailVerifiedAt: "emailVerifiedAt",
    createdAt: "createdAt",
    updatedAt: "updatedAt",
  ),
  token: "token",
);

class StudentLogic extends ChangeNotifier {
  final _key = "StudentLogic";
  final _cache = FlutterSecureStorage();

  LoggedUser _user = _defaultLoggedUser;
  LoggedUser get user => _user;

  Future readCacheUser() async {
    String? value = await _cache.read(key: _key);
    if (value == null) {
      _user = _defaultLoggedUser;
    } else {
      _user = loggedUserFromJson(value);
    }
    notifyListeners();
  }

  Future saveCacheUser(LoggedUser value) async {
    _user = value;
    await _cache.write(key: _key, value: loggedUserToJson(value));
    notifyListeners();
  }

  Future clearCacheUser() async{
    await _cache.delete(key: _key);
    notifyListeners();
  }
}
