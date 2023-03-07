import 'package:flutter/material.dart';
import 'package:meteor_music/common/env.dart';
import 'package:meteor_music/services/request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart';

const currentUserKey = 'CurrentUser';
const tokenKey = 'tokenKey';
const refreshTokenKey = 'refreshTokenKey';
const tokenCreateTimeKey = 'tokenCreateTimeKey';

var requests = [];
// 是否正在刷新的标记
var isRefreshing = false;
const _scopes = [
  'ugc-image-upload',
  'playlist-read-private',
  'playlist-read-collaborative',
  'playlist-modify-private',
  'playlist-modify-public',
  'user-follow-modify',
  'user-follow-read',
  'user-library-modify',
  'user-library-read',
  'user-read-email',
  'user-read-private'
];
var scopes = _scopes.join(' ');
var expiration = 3600;

class CurrentUser with ChangeNotifier {
  User? _value;
  String? accessToken;
  int? tokenCreateTime;

  User? get value => _value;

  void setCurrentUser(User data) {
    _value = data;
    notifyListeners();
  }

  setToken(String token) async {
    accessToken = token;

    notifyListeners();
  }

  setTokenTime() async {
    var now = DateTime.now().millisecondsSinceEpoch;
    tokenCreateTime = now;
    var pref = await SharedPreferences.getInstance();
    pref.setInt(tokenCreateTimeKey, now);
  }

  initTokenCreateTime(value) {
    tokenCreateTime = value;
  }

  CurrentUser(this._value);
  clear() {
    _value = null;
    accessToken = null;
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

  void listenerCredentialsRefreshed() async {
    var pref = await SharedPreferences.getInstance();
    var accessToken = pref.getString(tokenKey);
    var refreshToken = pref.getString(refreshTokenKey);
    var credentials = SpotifyApiCredentials(clientId, secret,
        accessToken: accessToken, refreshToken: refreshToken);
    // All of these fields are required for the Saved Credentials Flow
    final spotifyCredentials = SpotifyApiCredentials(
      credentials.clientId,
      credentials.clientSecret,
      accessToken: credentials.accessToken,
      refreshToken: credentials.refreshToken,
      scopes: _scopes,
      expiration: credentials.expiration,
    );
    SpotifyApi(spotifyCredentials,
        onCredentialsRefreshed: (SpotifyApiCredentials newCred) {
      pref.setString(tokenKey, newCred.accessToken!);
      pref.setString(refreshTokenKey, newCred.refreshToken!);
      accessToken = newCred.accessToken;
      notifyListeners();
    });
  }

  checkAccessToken() async {
    var pref = await SharedPreferences.getInstance();
    var diffDate = DateTime.now().millisecondsSinceEpoch - tokenCreateTime!;
    var duration = Duration(milliseconds: diffDate);
    // request refresh_token
    if (duration.inMinutes >= 2) {
      var res = await dio.get(
          'https://spotify-next-auth-path-yu.vercel.app/api/refresh',
          queryParameters: {'refresh_token': pref.getString(refreshTokenKey)});
      setToken(res.data['access_token']);
      setTokenTime();
    }
    return true;
  }
}
