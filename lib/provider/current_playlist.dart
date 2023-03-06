import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:meteor_music/services/youtube.dart';
import 'package:meteor_music/utils/primitive_utils.dart';
import 'package:meteor_music/utils/services_utils.dart';
import 'package:spotify/spotify.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';

final player = AudioPlayer();

class CurrentPlayList with ChangeNotifier {
  List<Map<String, dynamic>> playlist = [];
  int currentPlayIndex = 0;

  CurrentPlayList(this.currentPlayIndex, this.playlist);
  Map<String, dynamic> get currentPlaySong => playlist[currentPlayIndex];
  next() {}
  prev() {}
  setList(value) {
    playlist = value;
    notifyListeners();
  }

  fetchTrack(TrackSaved track, int index) async {
    currentPlayIndex = index;

    notifyListeners();
    final artists = (track.track!.artists!).map((ar) => ar.name!).toList();
    final title = ServiceUtils.getTitle(
      track.track!.name!,
      artists: artists,
      onlyCleanArtist: true,
    ).trim();
    final Directory directory = await getApplicationDocumentsDirectory();

    final File file = File('${directory.path}/$title.mp4');

    if (!file.existsSync()) {
      EasyLoading.show(status: 'loading...');
      try {
        VideoSearchList videos = await PrimitiveUtils.raceMultiple(
          () => youtube.search.search("${artists.join(", ")} - $title"),
        );
        var result = videos.where((video) => !video.isLive).take(10).toList();
        var ytVideo = result.first;
        StreamManifest trackManifest = await PrimitiveUtils.raceMultiple(
          () => youtube.videos.streams.getManifest(ytVideo.id),
        );
        final audioManifest = trackManifest.audioOnly;

        final chosenStreamInfo = audioManifest.withHighestBitrate();

        final ytUri = chosenStreamInfo.url.toString();
        var stream = youtube.videos.streamsClient.get(chosenStreamInfo);
        // / Open a file for writing.
        var fileStream = file.openWrite();

// Pipe all the content of the stream into the file.
        await stream.pipe(fileStream);

// Close the file.
        await fileStream.flush();
        await fileStream.close();
        EasyLoading.dismiss();
        await player.play(DeviceFileSource('${directory.path}/$title.mp4'));
      } catch (e) {
        EasyLoading.dismiss();
      }
      // will immediately start playing
    } else {
      await player.play(DeviceFileSource('${directory.path}/$title.mp4'));
    }
  }
}
