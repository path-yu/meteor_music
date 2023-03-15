import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isar/isar.dart';
import 'package:meteor_music/models/spotify_track.dart';
import 'package:meteor_music/provider/current_playlist.dart';
import 'package:meteor_music/provider/current_user.dart';
import 'package:meteor_music/router/router.dart';
import 'package:meteor_music/services/audio_service_hander.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify/spotify.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<Isar>? isar;
CurrentPlayList? ctxCurrentPlayList;
initIsar() async {
  final dir = await getApplicationSupportDirectory();
  isar = Isar.open(
    [SpotifyTrackSchema, ArtistItemSchema, ImageItemSchema],
    directory: dir.path,
    inspector: true,
  );
}

MyAudioHandler? audioHandler;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  User? userProfile;
  var userProfileData = prefs.getString(currentUserKey);
  var tokenData = prefs.getString(tokenKey);
  var tokenCreateTime = prefs.getInt(tokenCreateTimeKey);
  if (userProfileData != null) {
    var result = json.decode(userProfileData);
    userProfile = User.fromJson(result);
    userProfile.displayName = result['displayName'];
  }
  var currentUser = CurrentUser(userProfile);
  if (tokenData != null) {
    currentUser.setToken(tokenData);
  }
  if (tokenCreateTime != null) {
    currentUser.initTokenCreateTime(tokenCreateTime);
  }
  await initializeDateFormatting('en');

  initIsar();
  // store this in a singleton
  audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.meteor_music.app',
      androidNotificationChannelName: 'meteor_music',
      androidNotificationOngoing: true,
    ),
  );
  ctxCurrentPlayList = CurrentPlayList(0, []);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => currentUser),
      ChangeNotifierProvider(create: (_) => ctxCurrentPlayList)
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            routerConfig: baseRouter,
            builder: EasyLoading.init(),
            locale: const Locale('en'),
            title: 'meteor_music',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: Colors.blue, brightness: Brightness.dark),
          );
        });
  }
}
