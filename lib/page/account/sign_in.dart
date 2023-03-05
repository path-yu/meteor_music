import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meteor_music/common/env.dart';
import 'package:meteor_music/provider/current_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart';
import 'package:uni_links/uni_links.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;
  var autoUri = Uri.parse(
      'https://accounts.spotify.com/authorize?client_id=$clientId&redirect_uri=$redirectUrl&response_type=code&scope=$scopes');
  handleSignInClick() async {
    if (!await launchUrl(autoUri,
        mode: LaunchMode.externalNonBrowserApplication)) {
      throw Exception('Could not launch $redirectUrl');
    }

    //   // connect remote
    //   getUserProfile(token);
    // } on PlatformException catch (e) {
    //   showMessage(context: context, title: e.message.toString());
    //   return Future.error('$e.code: $e.message');
    // } on MissingPluginException {
    //   showMessage(context: context, title: 'not implemented');
    //   return Future.error('not implemented');
    // }
  }

  late StreamSubscription<Uri?> unSub;
  void getUserProfile(Map<String, String> parameters) async {
    var accessToken = parameters['access_token']!;
    setState(() {
      loading = true;
    });
    SpotifyApi.withAccessToken(accessToken).me.get().then((value) {
      context.read<CurrentUser>().setCurrentUser(value);
      context.read<CurrentUser>().setToken(accessToken);
      context.read<CurrentUser>().setTokenTime();
      SharedPreferences.getInstance().then((pref) {
        pref.setString(tokenKey, accessToken);
        pref.setString(refreshTokenKey, parameters['refresh_token']!);
        pref.setString(
            currentUserKey, json.encode(context.read<CurrentUser>().toJson()));
        context.go('/');
        setState(() {
          loading = false;
        });
      });
    });
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // the foreground or in the background.
      unSub = uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          if (uri.host == 'spotify-next-auth-blue.vercel.app') {
            Map<String, String> result = {};
            getUserProfile(uri.queryParameters);
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    super.dispose();
    unSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Auth',
        ),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.all(5),
          child: Center(
            child: loading
                ? const CircularProgressIndicator()
                : FractionallySizedBox(
                    widthFactor: 0.4,
                    child: ElevatedButton(
                        onPressed: handleSignInClick,
                        child: const Text('Sign In')),
                  ),
          )),
    );
  }
}
