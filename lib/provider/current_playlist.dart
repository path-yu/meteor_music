import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isar/isar.dart';
import 'package:meteor_music/main.dart';
import 'package:meteor_music/models/spotify_track.dart';
import 'package:meteor_music/services/youtube.dart';
import 'package:meteor_music/utils/primitive_utils.dart';
import 'package:meteor_music/utils/services_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

final player = AudioPlayer();
const currentPlayListIdKey = 'currentPlayListIdKey';
const currentPlayIndexKey = 'currentPlayIndexKey';
const currentPlayDurationKey = 'currentPlayDurationKey';

class CurrentPlayList with ChangeNotifier {
  List<Track> playlist = [];
  int currentPlayIndex = 0;
  int currentPlayDuration = 0;
  int duration = 0;
  double currentPlayPercentage = 0.0;
  bool isPlaying = false;
  bool slideIsTouch = false;
  String? currentPlayListId;
  setCurrentPlayListId(String id) {
    currentPlayListId = id;
    SharedPreferences.getInstance().then((value) {
      value.setString(currentPlayListIdKey, id);
    });
  }

  CurrentPlayList(this.currentPlayIndex, this.playlist);
  Future<SpotifyTrack?> get currentPlaySong async {
    if (playlist.isNotEmpty) {
      var track = playlist[currentPlayIndex];
      return await getTrackBySpotifyId(track);
    } else {
      return null;
    }
  }

  Track? get currentPlayTrack {
    return playlist.isNotEmpty ? playlist[currentPlayIndex] : null;
  }

  String get currentPlayDurationLabel {
    return formateDuration(currentPlayDuration);
  }

  String get durationLabel {
    return formateDuration(duration);
  }

  IconData get currentPlayIcon {
    return isPlaying ? Icons.pause : Icons.play_arrow;
  }

  listenPositionChange(Duration event) {
    if (!slideIsTouch) {
      updateCurrentDuration(event);
    }
  }

  handleSliderDown() {
    slideIsTouch = true;
  }

  handleSliderUp() {
    Future.delayed(const Duration(milliseconds: 200)).then(
      (value) {
        slideIsTouch = false;
        updatePlayerPosition();
      },
    );
  }

  updateCurrentDuration(Duration event) async {
    currentPlayDuration = event.inMilliseconds;
    currentPlayPercentage = (event.inMilliseconds / duration);
    notifyListeners();
    SharedPreferences.getInstance().then((value) {
      value.setInt(currentPlayDurationKey, event.inMilliseconds);
    });
  }

  initCurrentPosition() async {
    var track = await currentPlaySong;
    if (track != null) {
      SharedPreferences.getInstance().then((value) {
        currentPlayDuration = value.getInt(currentPlayDurationKey) ?? 0;
        currentPlayPercentage =
            (currentPlayDuration / track.duration!).toDouble();
        notifyListeners();
      });
    }
  }

  updateCurrentPercentage(double value) async {
    currentPlayPercentage = value;
    currentPlayDuration = (duration.toDouble() * value).toInt();
    notifyListeners();
  }

  updatePlayerPosition() {
    player.seek(Duration(milliseconds: currentPlayDuration));
    SharedPreferences.getInstance().then((value) {
      value.setInt(currentPlayDurationKey, currentPlayDuration);
    });
  }

  next() {
    int index;
    player.pause();
    reset();
    if (currentPlayIndex == playlist.length - 1) {
      index = 0;
    } else {
      index = currentPlayIndex + 1;
    }
    fetchTrack(playlist[index], index);
  }

  String get authorName =>
      currentPlayTrack!.artists!.map((e) => e.name).toList().join(',');
  prev() {
    int index;
    player.pause();
    if (currentPlayIndex == 0) {
      index = playlist.length - 1;
    } else {
      index = currentPlayIndex - 1;
    }
    reset();
    fetchTrack(playlist[index], index);
  }

  setList(List<Track> value) {
    playlist = value;
    notifyListeners();
  }

  reset() {
    currentPlayDuration = 0;
    currentPlayPercentage = 0;
  }

  setCurrentPlayIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(currentPlayIndexKey, index);
    currentPlayIndex = index;
    notifyListeners();
  }

  pause() {
    isPlaying = false;
    player.pause();
    notifyListeners();
  }

  play() {
    if (player.source != null) {
      isPlaying = true;
      player.resume();
      notifyListeners();
    } else {
      fetchTrack(currentPlayTrack!, currentPlayIndex);
    }
  }

  togglePlay() {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  writeTrack(
    Track data, {
    required String youtubeId,
    required String path,
    required duration,
  }) async {
    var ctx = await isar;
    final spotifyTrack = SpotifyTrack();
    spotifyTrack.spotifyId = data.id;
    spotifyTrack.name = data.name;
    spotifyTrack.youtubeId = youtubeId;
    spotifyTrack.duration = duration;
    for (var element in data.artists!) {
      final artistItem = ArtistItem();
      artistItem.spotifyId = element.id;
      artistItem.name = element.name!;
      artistItem.href = element.href!;
      spotifyTrack.artist.add(artistItem);
      await ctx!.writeTxn(() async {
        await ctx.artistItems.put(artistItem);
      });
    }
    for (var element in data.album!.images!) {
      final imageItem = ImageItem();
      imageItem.url = element.url!;
      imageItem.width = element.width!;
      imageItem.height = element.height!;
      await ctx!.writeTxn(() async {
        await ctx.imageItems.put(imageItem);
      });
    }
    await ctx!.writeTxn(() async {
      await ctx.spotifyTracks.put(spotifyTrack);
      await spotifyTrack.artist.save();
      await spotifyTrack.images.save();
    });
  }

  Future<SpotifyTrack?> getTrackBySpotifyId(Track track) {
    return isar!.then((value) async {
      var result = await value.spotifyTracks
          .filter()
          .spotifyIdEqualTo(track.id)
          .findFirst();
      return result;
    });
  }

  fetchTrack(Track track, int index) async {
    setCurrentPlayIndex(index);
    final artists = (track.artists!).map((ar) => ar.name!).toList();
    final title = ServiceUtils.getTitle(
      track.name!,
      artists: artists,
      onlyCleanArtist: true,
    ).trim();
    final Directory directory = await getApplicationDocumentsDirectory();
    SpotifyTrack? cacheTrack;
    final File file = File('${directory.path}/$title.mp3');
    cacheTrack = await getTrackBySpotifyId(track);
    if (cacheTrack == null) {
      EasyLoading.show(status: 'loading');
      try {
        VideoSearchList videos = await PrimitiveUtils.raceMultiple(
          () => youtube.search.search("${artists.join(", ")} - $title"),
        );
        var result = videos.where((video) => !video.isLive).take(10).toList();
        var ytVideo = result.first;
        ytVideo.duration;
        StreamManifest trackManifest = await PrimitiveUtils.raceMultiple(
          () => youtube.videos.streams.getManifest(ytVideo.id),
        );
        final audioManifest = trackManifest.audioOnly;
        final chosenStreamInfo = audioManifest.withHighestBitrate();
        var stream = youtube.videos.streamsClient.get(chosenStreamInfo);
        var fileStream = file.openWrite();
        await stream.pipe(fileStream);

        await fileStream.flush();
        await fileStream.close();
        EasyLoading.dismiss();
        await player.play(DeviceFileSource(file.path));
        writeTrack(track,
            youtubeId: ytVideo.id.toString(),
            path: file.path,
            duration: ytVideo.duration!.inMilliseconds);
        duration = ytVideo.duration!.inMilliseconds;
        addMediaItem(track, duration);
        play();
      } catch (e) {
        EasyLoading.dismiss();
      }
    } else {
      duration = cacheTrack.duration!;
      await player.play(DeviceFileSource(file.path),
          position: Duration(milliseconds: currentPlayDuration));
      addMediaItem(track, duration);
      play();
    }
  }
}

addMediaItem(Track track, int duration) {
  final item = MediaItem(
    id: track.id!,
    album: track.album!.name!,
    title: track.name!,
    artist: track.artists!.map((e) => e.name).join(','),
    duration: Duration(milliseconds: duration),
    artUri: Uri.parse(track.album!.images!.last.url!),
  );
  audioHandler!.addItem(item);
}

formateDuration(int milliseconds) {
  var format = DateFormat.ms();
  return format.format(DateTime.fromMillisecondsSinceEpoch(milliseconds));
}
