import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart';

const currentUserKey = 'CurrentUser';
const tokenKey = 'tokenKey';

class CurrentUser with ChangeNotifier {
  User? _value;
  String? accessToken;
  String? refreshToken;

  User? get value => _value;

  void setCurrentUser(User data) {
    _value = data;
    notifyListeners();
  }

  setToken(Map data) {
    accessToken = data['access_token'];
    refreshToken = data['refresh_token'];
  }

  CurrentUser(this._value);
  clear() {
    _value = null;
    accessToken = null;
    refreshToken = null;
    SharedPreferences.getInstance().then((pre) {
      pre.remove(currentUserKey);
      pre.remove(tokenKey);
    });
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['birthdate'] = _value?.birthdate;
    data['country'] = _value?.country;
    data['displayName'] = _value?.displayName;
    data['email'] = _value?.email;
    data['id'] = _value?.id;
    data['images'] = _value?.images;
    data['href'] = _value?.href;
    data['uri'] = _value?.uri;
    data['type'] = _value?.type;
    data['product'] = _value?.product;
    return data;
  }
}
