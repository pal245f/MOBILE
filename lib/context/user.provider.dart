import 'package:flutter/foundation.dart';
import 'user.model.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;

  void setUser(User user, String token) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _token = null;
    notifyListeners();
  }
}
