import 'package:las_aventuras_de_regina/core/audio/game_audio.dart';
import 'package:las_aventuras_de_regina/features/world/data/progress_repository.dart';
import 'package:las_aventuras_de_regina/features/world/domain/progress.dart';

class MemoryProgressRepository implements ProgressRepository {
  MemoryProgressRepository([GameProgress? initial])
    : value = initial ?? GameProgress();
  GameProgress value;
  bool failRead = false;
  bool failWrite = false;
  int writes = 0;
  @override
  Future<GameProgress> load() async {
    if (failRead) throw StateError('read');
    return GameProgress.fromJson(value.toJson());
  }

  @override
  Future<void> save(GameProgress progress) async {
    if (failWrite) throw StateError('write');
    writes++;
    value = GameProgress.fromJson(progress.toJson());
  }
}

class FakeAudio implements GameAudio {
  final played = <GameSound>[];
  int stops = 0;
  final spoken = <List<String>>[];
  int voiceStops = 0;
  @override
  Future<void> speak(List<String> clips) async {
    if (fail) throw StateError("voice");
    spoken.add(List.of(clips));
  }

  @override
  Future<void> stopVoice() async {
    voiceStops++;
  }

  bool fail = false;
  @override
  Future<void> play(GameSound sound) async {
    if (fail) throw StateError('audio');
    played.add(sound);
  }

  @override
  Future<void> stop() async {
    stops++;
  }
}
