import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meteor_music/common/common.dart';
import 'package:meteor_music/provider/current_user.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' hide Image;

final List<String> _playlist = [
  'Liked songs',
];
List<PlaylistSimple> _featuredPlaylist = [];
List<PlaylistSimple> Recommendations = [];

class HomeScreen extends StatefulWidget {
  final void Function(int index, {String? id}) updateIndex;
  const HomeScreen(this.updateIndex, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  bool loading = false;
  List<PlaylistSimple> featuredPlaylist = [];
  @override
  void initState() {
    // TODO: implement initState
    initData();
  }

  initData() async {
    if (_featuredPlaylist.isNotEmpty) {
      setState(() {
        loading = false;
        featuredPlaylist = _featuredPlaylist.toList();
      });
      return;
    }
    setState(() {
      loading = true;
    });
    await context.read<CurrentUser>().checkAccessToken();
    // get liked songs
    SpotifyApi.withAccessToken(context.read<CurrentUser>().accessToken!)
        .playlists
        .featured
        .all()
        .then((value) {
      setState(() {
        featuredPlaylist = value.toList();
        _featuredPlaylist = value.toList();
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? baseLoading
        : CustomScrollView(
            key: const PageStorageKey('home'),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  // color: Colors.black,
                  padding: const EdgeInsets.only(right: 15, top: 20, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Good evening',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.grey.shade900,
                            splashRadius: 20,
                            icon: const Icon(Icons.exit_to_app,
                                size: 26, color: Colors.white),
                            onPressed: () {
                              context.read<CurrentUser>().clear();
                              context.go('/sign_in');
                            },
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.grey.shade900,
                            splashRadius: 20,
                            icon: const Icon(Icons.notifications_outlined,
                                size: 26, color: Colors.white),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 5),
                          IconButton(
                            padding: EdgeInsets.zero,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.grey.shade900,
                            splashRadius: 20,
                            icon: const Icon(Icons.more_time_sharp,
                                size: 26, color: Colors.white),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 5),
                          IconButton(
                            padding: EdgeInsets.zero,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.grey.shade900,
                            splashRadius: 20,
                            icon: const Icon(Icons.settings_outlined,
                                size: 26, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(
                    left: 20, top: 10, right: 20, bottom: 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    childCount: 1,
                    (context, index) {
                      return InkWell(
                        onTap: () {
                          widget.updateIndex(3,id: '0');
                        },
                        child: Stack(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade900,
                                  borderRadius: BorderRadius.circular(3)),
                            ),
                            Image.network(
                                'https://t.scdn.co/images/3099b3803ad9496896c43f22fe9be8c4.png'),
                            Positioned(
                              right: 10,
                              top: 20,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.23,
                                height: 35,
                                child: Text(
                                  _playlist[index],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 3),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverToBoxAdapter(
                  child: Text('Featured Playlists',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  height: 190,
                  child: ListView.builder(
                    key: const PageStorageKey('Featured'),
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredPlaylist.length,
                    itemBuilder: (context, index) {
                      var item = featuredPlaylist.elementAt(index);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              widget.updateIndex(3, id: item.id);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(item.images!.first.url!),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: SizedBox(
                              width: 110,
                              child: Text(
                                item.name!,
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          Container(
                            width: 130,
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              item.description!,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              )
            ],
          );
  }
}
