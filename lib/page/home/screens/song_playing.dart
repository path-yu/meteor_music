import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meteor_music/provider/current_playlist.dart';
import 'package:provider/provider.dart';

class SongPlaying extends StatefulWidget {
  const SongPlaying({super.key});

  @override
  State<SongPlaying> createState() => _SongPlayingState();
}

class _SongPlayingState extends State<SongPlaying> {
  double _sliderValue = 0.2;
  @override
  Widget build(BuildContext context) {
    var currentPlayTrack = context.watch<CurrentPlayList>().currentPlayTrack;
    var authorName = context.watch<CurrentPlayList>().authorName;
    var url = currentPlayTrack!.album!.images!.first.url;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            splashRadius: 20,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 35,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Column(
            children: const [
              Text(
                'PLAYING FROM YOUR LIBRARY',
                style: TextStyle(
                    color: Colors.white, fontSize: 11, letterSpacing: 1),
              ),
              Text(
                'Liked Songs',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w600),
              )
            ],
          ),
          actions: [
            IconButton(
              splashRadius: 20,
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Image.network(
                url!,
                height: 300,
              )),
              const SizedBox(
                height: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentPlayTrack.name!,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    authorName,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  )
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  SliderTheme(
                    data: const SliderThemeData(
                        trackHeight: 2,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 5),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 0)),
                    child: Listener(
                      onPointerUp: (_) {
                        context.read<CurrentPlayList>().handleSliderUp();
                      },
                      onPointerDown: (event) {
                        context.read<CurrentPlayList>().handleSliderDown();
                      },
                      child: Slider(
                        thumbColor: Colors.white,
                        inactiveColor: Colors.grey.shade700,
                        value: context
                            .watch<CurrentPlayList>()
                            .currentPlayPercentage,
                        activeColor: Colors.white,
                        onChanged: (double value) {
                          _sliderValue = value;
                          context
                              .read<CurrentPlayList>()
                              .updateCurrentPercentage(value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context
                            .watch<CurrentPlayList>()
                            .currentPlayDurationLabel,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade300),
                      ),
                      Text(
                        context.watch<CurrentPlayList>().durationLabel,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade300),
                      )
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                    onPressed: () {},
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                    onPressed: () {
                      context.read<CurrentPlayList>().prev();
                    },
                    icon: const Icon(
                      CupertinoIcons.backward_end_fill,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      onPressed: () {
                        context.read<CurrentPlayList>().togglePlay();
                      },
                      icon: Icon(
                        context.watch<CurrentPlayList>().currentPlayIcon,
                        size: 35,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                    onPressed: () {
                      context.read<CurrentPlayList>().next();
                    },
                    icon: const Icon(
                      CupertinoIcons.forward_end_fill,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                    onPressed: () {},
                    icon: const Icon(
                      CupertinoIcons.stop_circle,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                ],
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     IconButton(
              //         padding: EdgeInsets.zero,
              //         splashRadius: 20,
              //         onPressed: () {},
              //         icon: const Icon(Icons.menu, color: Colors.grey))
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
