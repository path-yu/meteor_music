import 'package:go_router/go_router.dart';
import 'package:meteor_music/page/account/sign_in.dart';
import 'package:meteor_music/page/home/home.dart';
import 'package:meteor_music/provider/current_user.dart';
import 'package:provider/provider.dart';

// GoRouter configuration
final baseRouter = GoRouter(
  redirect: (context, state) {
    if (context.read<CurrentUser>().value == null) {
      return '/sign_in';
    } else {
      return null;
    }
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/sign_in',
      builder: (context, state) => const LoginPage(),
    ),
  ],
);
