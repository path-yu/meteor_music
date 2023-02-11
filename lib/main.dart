import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meteor_music/provider/current_user.dart';
import 'package:meteor_music/router/router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify/spotify.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  User? userProfile;
  var userProfileData = prefs.getString(currentUserKey);
  var tokenData = prefs.getString(tokenKey);
  if (userProfileData != null) {
    var result = json.decode(userProfileData);
    userProfile = User.fromJson(result);
    userProfile.displayName = result['displayName'];
  }
  var currentUser = CurrentUser(userProfile);
  if (tokenData != null) {
    currentUser.setToken(json.decode(tokenData));
  }
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => currentUser)],
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
            title: 'meteor_music',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: Colors.blue, brightness: Brightness.dark),
          );
        });
  }
}
