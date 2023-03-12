import 'package:isar/isar.dart';
part 'spotify_track.g.dart';

@collection
class SpotifyTrack {
  Id? id;

  String? name;

  String? spotifyId;
  String? youtubeId;
  String? path;

  int? duration;
  final artist = IsarLinks<ArtistItem>();

  final images = IsarLinks<ImageItem>();
}

@collection
class ImageItem {
  Id? id;

  late int width;
  late int height;

  late String url;
}

@collection
class ArtistItem {
  Id? id;
  String? spotifyId;
  late String href;
  late String name;
}
