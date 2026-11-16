import 'package:audioplayers/audioplayers.dart';

/// Musik latar dari assets/music/. Berulang terus sampai dihentikan.
/// Jika file belum ada, aplikasi tetap berjalan tanpa musik.
class Music {
  Music._();

  static const track = 'bgm.mp3';

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play() async {
    try {
      if (_player.state == PlayerState.playing) return;
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.6);
      await _player.play(AssetSource('music/$track'));
    } catch (_) {
      // File belum ditambahkan atau gagal diputar: lanjut tanpa musik.
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }
}
