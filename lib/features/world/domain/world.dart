import 'dart:math';

enum ActivityKind { counting, letters }

class ForestLevel {
  const ForestLevel(this.id, this.title, this.kind, this.range);
  final int id;
  final String title;
  final ActivityKind kind;

  /// Mayor cantidad para contar o cantidad de letras de REGINA introducidas.
  final int range;
}

const forestLevels = [
  ForestLevel(1, 'Las estrellas perdidas', ActivityKind.counting, 2),
  ForestLevel(2, 'La magia de R', ActivityKind.letters, 1),
  ForestLevel(3, 'Un cielo de estrellas', ActivityKind.counting, 3),
  ForestLevel(4, 'R, E y G brillan', ActivityKind.letters, 3),
  ForestLevel(5, 'Cinco deseos', ActivityKind.counting, 5),
  ForestLevel(6, 'El nombre de Regina', ActivityKind.letters, 6),
];

class Question {
  Question(this.kind, this.answer, List<String> options)
    : options = List.unmodifiable(options);
  final ActivityKind kind;
  final String answer;
  final List<String> options;
  String get learningKey => '${kind.name}:$answer';
  int get starCount => int.parse(answer);
}

/// Lógica independiente de Flutter, con aleatoriedad inyectable para las pruebas.
class AdventureSession {
  AdventureSession(this.level, {Random? random})
    : _random = random ?? Random() {
    final targets =
        level.kind == ActivityKind.letters
            ? 'REGINA'.substring(0, level.range).split('')
            : List.generate(level.range, (i) => '${i + 1}');
    _plan = List.generate(
      max(5, targets.length),
      (i) => targets[i % targets.length],
    )..shuffle(_random);
    question = _makeQuestion();
  }

  final ForestLevel level;
  final Random _random;
  List<String> _plan = [];
  int round = 0;
  bool answered = false;
  bool hintVisible = false;
  late Question question;
  int get totalRounds => _plan.length;
  bool get finished => round == totalRounds - 1 && answered;

  Question _makeQuestion() {
    if (level.kind == ActivityKind.counting) {
      final count = int.parse(_plan[round]);
      final pool =
          List.generate(max(3, level.range), (i) => '${i + 1}')
            ..remove('$count')
            ..shuffle(_random);
      final options = ['$count', ...pool.take(2)]..shuffle(_random);
      return Question(level.kind, '$count', options);
    }
    final target = _plan[round];
    final others =
        'REGINA'.split('')
          ..remove(target)
          ..shuffle(_random);
    final options = [target, ...others.take(2)]..shuffle(_random);
    return Question(level.kind, target, options);
  }

  /// Los toques repetidos tras acertar no generan nuevas recompensas.
  bool? answer(String choice) {
    if (answered || !question.options.contains(choice)) return null;
    final correct = choice == question.answer;
    if (correct) {
      answered = true;
    } else {
      hintVisible = true;
    }
    return correct;
  }

  void next() {
    if (!answered || finished) return;
    round++;
    answered = false;
    hintVisible = false;
    question = _makeQuestion();
  }
}
