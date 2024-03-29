// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meteor_music/page/home/screens/home_screen.dart';
import 'package:meteor_music/page/home/screens/library.dart';
import 'package:meteor_music/page/home/screens/playlist_screen.dart';
import 'package:meteor_music/page/home/screens/search_screen.dart';
import 'package:meteor_music/page/home/screens/song_playing.dart';
import 'package:meteor_music/provider/current_playlist.dart';
import 'package:meteor_music/provider/current_user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart' hide Image;

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SongPlaying();
    },
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0, 1);
      const end = Offset(0, 0);
      const curve = Curves.easeInCubic;

      var tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class UserAccount extends StatefulWidget {
  const UserAccount({super.key});

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  int selectedIndex = 0;
  final List<Color> _colorsRandom = [];
  String playListId = '0';
  @override
  void initState() {
    super.initState();
    for (int i = 0; i <= 10; i++) {
      _colorsRandom
          .add(Colors.primaries[Random().nextInt(Colors.primaries.length)]);
    }

    player.onPlayerComplete.listen((event) {
      context.read<CurrentPlayList>().next();
    });

    handleListenPositionChange();
    initPlayList();
  }

  handleListenPositionChange() async {
    player.onPositionChanged.listen((event) async {
      context.read<CurrentPlayList>().listenPositionChange(event);
    });
  }

  void initPlayList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var playListId = prefs.getString(currentPlayListIdKey);
    if (playListId == '0') {
      await context.read<CurrentUser>().checkAccessToken();
      // get liked songs
      SpotifyApi.withAccessToken(context.read<CurrentUser>().accessToken!)
          .tracks
          .me
          .saved
          .all()
          .then((value) {
        setState(() {
          context
              .read<CurrentPlayList>()
              .setList(value.map((e) => e.track!).toList());
          context.read<CurrentPlayList>().initCurrentPosition();
          context
              .read<CurrentPlayList>()
              .setCurrentPlayIndex(prefs.getInt(currentPlayIndexKey)!);
        });
      });
    }
  }

  void updateIndex(int newIndex, {String? id}) {
    setState(() {
      selectedIndex = newIndex;
      print(id);
      if (id != null) {
        playListId = id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var currentPlayTrack = context.watch<CurrentPlayList>().currentPlayTrack;
    List<Widget> screens = [
      HomeScreen(updateIndex),
      SearchScreen(_colorsRandom),
      const Library(),
      PlayListScreen(
        updateIndex,
        id: playListId,
      )
    ];

    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Scaffold(
            appBar: (selectedIndex == 2)
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(91),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: AppBar(
                        elevation: 0,
                        backgroundColor: selectedIndex == 2
                            ? Colors.black
                            : Colors.transparent,
                        toolbarHeight: 90,
                        leading: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        title: selectedIndex == 2
                            ? const Text(
                                'Your Library',
                                style: TextStyle(color: Colors.white),
                              )
                            : null,
                        actions: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            splashRadius: 20,
                            onPressed: () {
                              print('search');
                            },
                            icon: const Icon(
                              CupertinoIcons.search,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            splashRadius: 20,
                            onPressed: () {
                              print('add');
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
            extendBody: true,
            body: screens[selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
                iconSize: 26,
                unselectedFontSize: 12,
                selectedFontSize: 12,
                type: BottomNavigationBarType.fixed,
                currentIndex: selectedIndex > 2 ? 0 : selectedIndex,
                unselectedItemColor: Colors.grey,
                selectedItemColor: Colors.white,
                backgroundColor: Colors.black.withOpacity(0.93),
                onTap: (value) => setState(() {
                      selectedIndex = value;
                    }),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.search),
                    label: "Search",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.recent_actors),
                    label: "Your Library",
                  )
                ]),
          ),
          currentPlayTrack == null
              ? Container()
              : Positioned(
                  bottom: 55,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(_createRoute()),
                      child: Material(
                        borderRadius: BorderRadius.circular(5),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade900,
                                  borderRadius: BorderRadius.circular(5)),
                              height: 53,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.network(
                                    currentPlayTrack.album!.images!.last.url!,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentPlayTrack.name!,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      Text(
                                        context
                                            .watch<CurrentPlayList>()
                                            .authorName,
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  )),
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            context
                                                .read<CurrentPlayList>()
                                                .togglePlay();
                                          },
                                          icon: Icon(
                                            context
                                                    .watch<CurrentPlayList>()
                                                    .isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            size: 22,
                                            color: Colors.white,
                                          ))
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: SliderTheme(
                                data: SliderThemeData(
                                    activeTrackColor: Colors.white,
                                    trackHeight: 0.1,
                                    overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 0),
                                    thumbShape: SliderComponentShape.noOverlay),
                                child: Slider(
                                  inactiveColor: Colors.grey,
                                  value: context
                                      .watch<CurrentPlayList>()
                                      .currentPlayPercentage,
                                  onChanged: (double value) {},
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
