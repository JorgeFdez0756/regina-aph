import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/progress.dart';

abstract interface class ProgressRepository {
  Future<GameProgress> load();
  Future<void> save(GameProgress progress);
}

/// Android conserva este JSON en almacenamiento privado; no requiere permisos.
class AndroidProgressRepository implements ProgressRepository {
  static const channel = MethodChannel('regina/world');

  @override
  Future<GameProgress> load() async {
    final json = await channel.invokeMethod<String>('loadProgress');
    if (json == null) return GameProgress();
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic>)
      throw const FormatException('Progreso inválido');
    return GameProgress.fromJson(decoded);
  }

  @override
  Future<void> save(GameProgress progress) =>
      channel.invokeMethod<void>('saveProgress', jsonEncode(progress.toJson()));
}
