import 'package:meteor_music/services/index.dart';
import 'package:spotify/spotify.dart';

Future<Artist> getAriistsById({id = '0OdUWJ0sBjDrqHygGUXeCF'}) {
  return spotify.artists.get(id);
}
