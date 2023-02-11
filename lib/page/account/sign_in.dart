import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meteor_music/provider/current_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

var _url = Uri.parse(
    'https://accounts.spotify.com/authorize?response_type=code&client_id=ba7d6d4a56644b198aa47bb9d88cfc17&redirect_uri=https://spotify-next-auth-blue.vercel.app');

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url,
        mode: LaunchMode.externalNonBrowserApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  late StreamSubscription<Uri?> unSub;
  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // the foreground or in the background.
      unSub = uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          if (uri.host == 'spotify-next-auth-blue.vercel.app') {
            var result = {};
            uri.queryParameters.forEach((k, v) {
              result[k] = v;
            });
            setState(() {
              loading = true;
            });
            // getUserProfile
            SpotifyApi.withAccessToken(result['access_token'])
                .me
                .get()
                .then((value) {
              context.read<CurrentUser>().setCurrentUser(value);
              context.read<CurrentUser>().setToken(result);
              SharedPreferences.getInstance().then((pref) {
                pref.setString(tokenKey, json.encode(result));
                pref.setString(currentUserKey,
                    json.encode(context.read<CurrentUser>().toJson()));
                context.go('/');
              });
            });
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
                        onPressed: () {
                          _launchUrl();
                        },
                        child: const Text('Sign In')),
                  ),
          )),
    );
  }
}
