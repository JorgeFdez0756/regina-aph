import 'world.dart';

class LearningRecord {
  const LearningRecord({this.attempts = 0, this.correct = 0});
  final int attempts;
  final int correct;
  LearningRecord record(bool success) => LearningRecord(
    attempts: attempts + 1,
    correct: correct + (success ? 1 : 0),
  );
}

class GameProgress {
  GameProgress({
    Map<int, int> levelStars = const {},
    Map<String, LearningRecord> learning = const {},
    this.soundEnabled = true,
    this.accessory = 0,
  }) : levelStars = Map.unmodifiable(levelStars),
       learning = Map.unmodifiable(learning);

  final Map<int, int> levelStars;
  final Map<String, LearningRecord> learning;
  final bool soundEnabled;
  final int accessory;

  GameProgress wear(int id) {
    if (id < 0 || id > forestLevels.length || (id != 0 && !isCompleted(id)))
      return this;
    return GameProgress(
      levelStars: levelStars,
      learning: learning,
      soundEnabled: soundEnabled,
      accessory: id,
    );
  }

  int get stars => levelStars.values.fold(0, (sum, value) => sum + value);
  bool isUnlocked(int id) => id == 1 || levelStars.containsKey(id - 1);
  bool isCompleted(int id) => levelStars.containsKey(id);

  GameProgress withSound(bool enabled) => GameProgress(
    levelStars: levelStars,
    learning: learning,
    soundEnabled: enabled,
    accessory: accessory,
  );

  GameProgress record(Question question, bool correct) => GameProgress(
    levelStars: levelStars,
    soundEnabled: soundEnabled,
    accessory: accessory,
    learning: {
      ...learning,
      question.learningKey: (learning[question.learningKey] ??
              const LearningRecord())
          .record(correct),
    },
  );

  GameProgress complete(int id) {
    if (!forestLevels.any((level) => level.id == id) || !isUnlocked(id))
      return this;
    return GameProgress(
      levelStars: {...levelStars, id: 3},
      accessory: isCompleted(id) ? accessory : id,
      learning: learning,
      soundEnabled: soundEnabled,
    );
  }

  Map<String, Object> toJson() => {
    'version': 2,
    'accessory': accessory,
    'sound': soundEnabled,
    'levels': levelStars.map((key, value) => MapEntry('$key', value)),
    'learning': learning.map(
      (key, value) =>
          MapEntry(key, {'attempts': value.attempts, 'correct': value.correct}),
    ),
  };

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1 && json['version'] != 2)
      throw const FormatException('Versión de progreso no compatible');
    final levels = <int, int>{};
    final rawLevels = json['levels'];
    if (rawLevels is! Map ||
        json['sound'] is! bool ||
        json['learning'] is! Map) {
      throw const FormatException('Progreso incompleto');
    }
    // Solo restaurar un sendero continuo: nunca desbloquear niveles por datos inválidos.
    for (final level in forestLevels) {
      final value = rawLevels['${level.id}'];
      if (value is! int || value < 1 || value > 3) break;
      levels[level.id] = value;
    }
    final learning = <String, LearningRecord>{};
    for (final entry in (json['learning'] as Map).entries) {
      final value = entry.value;
      if (entry.key is String && value is Map) {
        final attempts = value['attempts'];
        final correct = value['correct'];
        if (attempts is int &&
            correct is int &&
            correct >= 0 &&
            attempts >= correct) {
          learning[entry.key as String] = LearningRecord(
            attempts: attempts,
            correct: correct,
          );
        }
      }
    }
    final savedAccessory = json['version'] == 2 ? json['accessory'] : 0;
    final accessory =
        savedAccessory is int &&
                savedAccessory >= 0 &&
                savedAccessory <= forestLevels.length &&
                (savedAccessory == 0 || levels.containsKey(savedAccessory))
            ? savedAccessory
            : 0;
    return GameProgress(
      accessory: accessory,
      levelStars: levels,
      learning: learning,
      soundEnabled: json['sound'] as bool,
    );
  }
}
