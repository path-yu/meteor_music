import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:meteor_music/main.dart';
import 'package:meteor_music/provider/current_playlist.dart';

class MyAudioHandler extends BaseAudioHandler {
  // mix in default seek callback implementations

  // The most common callbacks:
  @override
  Future<void> play() async {
    if (ctxCurrentPlayList != null) {
      ctxCurrentPlayList!.play();
    }
    // All 'play' requests from all origins route to here. Implement this
    // callback to start playing audio appropriate to your app. e.g. music.
  }

  MyAudioHandler() {
    player.onPlayerStateChanged.listen((state) async {
      if (state != PlayerState.completed) {
        playbackState.add(await _transformEvent());
      }
    });

    player.onPositionChanged.listen((pos) async {
      playbackState.add(await _transformEvent());
    });
  }
  @override
  Future<void> pause() async {
    if (ctxCurrentPlayList != null) {
      ctxCurrentPlayList!.pause();
    }
  }

  @override
  Future<void> skipToNext() {
    if (ctxCurrentPlayList != null) {
      ctxCurrentPlayList!.next();
    }
    return super.skipToNext();
  }

  @override
  Future<void> skipToPrevious() {
    if (ctxCurrentPlayList != null) {
      ctxCurrentPlayList!.prev();
    }
    return super.skipToPrevious();
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> seek(Duration position) async {
    if (ctxCurrentPlayList != null) {
      ctxCurrentPlayList!.updateCurrentDuration(position);
      ctxCurrentPlayList!.updatePlayerPosition();
    }
  }

  void addItem(MediaItem item) {
    mediaItem.add(item);
  }

  Future<PlaybackState> _transformEvent() async {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        player.state == PlayerState.playing
            ? MediaControl.pause
            : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: {
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 2],
      playing: player.state == PlayerState.playing,
      updatePosition: (await player.getCurrentPosition()) ?? Duration.zero,
      processingState: player.state == PlayerState.paused
          ? AudioProcessingState.buffering
          : player.state == PlayerState.playing
              ? AudioProcessingState.ready
              : AudioProcessingState.idle,
    );
  }
}
