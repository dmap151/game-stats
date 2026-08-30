import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database_service.dart';
import '../data/models/game.dart';
import '../data/models/match_record.dart';
import '../data/models/player.dart';

/// Structured preview of a parsed backup before applying it.
class BackupPreview {
  final int version;
  final DateTime? exportedAt;
  final int gamesCount;
  final int playersCount;
  final int matchesCount;
  final int imagesCount;
  final Map<String, dynamic> rawJson;
  final Directory? tempImagesDir;

  const BackupPreview({
    required this.version,
    this.exportedAt,
    required this.gamesCount,
    required this.playersCount,
    required this.matchesCount,
    required this.imagesCount,
    required this.rawJson,
    this.tempImagesDir,
  });
}

class BackupService {
  final DatabaseService _db;
  final Future<Directory> Function()? tempDirProvider;
  final Future<Directory> Function()? docDirProvider;

  BackupService(
    this._db, {
    this.tempDirProvider,
    this.docDirProvider,
  });

  Future<Directory> _getTempDir() async {
    if (tempDirProvider != null) return await tempDirProvider!();
    return await getTemporaryDirectory();
  }

  Future<Directory> _getDocDir() async {
    if (docDirProvider != null) return await docDirProvider!();
    return await getApplicationDocumentsDirectory();
  }

  /// Exports the entire database including all associated images into a single `.zip` file.
  Future<File> createBackupArchive() async {
    final games = await _db.getAllGames();
    final players = await _db.getAllPlayers();
    final matches = await _db.getAllMatchRecords();

    final archive = Archive();
    final imagesMap = <String, String>{}; // original path -> archive relative path
    int imageIndex = 0;

    String? registerImage(String? originalPath, String folder) {
      if (originalPath == null || originalPath.isEmpty) return null;
      final file = File(originalPath);
      if (!file.existsSync()) return null;

      if (imagesMap.containsKey(originalPath)) {
        return imagesMap[originalPath];
      }

      final ext = p.extension(originalPath);
      final archiveRelPath = 'images/$folder/img_${++imageIndex}$ext';
      imagesMap[originalPath] = archiveRelPath;

      try {
        final bytes = file.readAsBytesSync();
        archive.addFile(ArchiveFile(archiveRelPath, bytes.length, bytes));
      } catch (e) {
        debugPrint('Warning: Could not read image file $originalPath: $e');
        return null;
      }

      return archiveRelPath;
    }

    // Process games
    final gamesJson = games.map((g) {
      final relImg = registerImage(g.imagePath, 'games');
      return {
        'name': g.name,
        'image': relImg,
      };
    }).toList();

    // Process players
    final playersJson = players.map((p) {
      final relImg = registerImage(p.imagePath, 'players');
      return {
        'name': p.name,
        'image': relImg,
      };
    }).toList();

    // Process matches
    final matchesJson = matches.map((m) {
      final relImg = registerImage(m.imagePath, 'matches');
      final relImages = <String>[];
      for (final path in m.imagePaths) {
        final r = registerImage(path, 'matches');
        if (r != null) relImages.add(r);
      }

      return {
        'gameName': m.game.value?.name ?? '',
        'date': m.date.toIso8601String(),
        'numberOfPlayers': m.numberOfPlayers,
        'image': relImg,
        'imagePaths': relImages,
        'latitude': m.latitude,
        'longitude': m.longitude,
        'playerScores': m.playerScores.map((s) => {
          'playerName': s.playerName ?? '',
          'placement': s.placement,
          'score': s.score,
        }).toList(),
      };
    }).toList();

    final dataJson = {
      'version': 1,
      'app': 'game_stats',
      'exportedAt': DateTime.now().toIso8601String(),
      'games': gamesJson,
      'players': playersJson,
      'matches': matchesJson,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(dataJson);
    final jsonBytes = utf8.encode(jsonString);
    archive.addFile(ArchiveFile('data.json', jsonBytes.length, jsonBytes));

    // Encode to ZIP
    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);
    if (zipBytes == null) {
      throw Exception('Fehler beim Erstellen des Backup-Archivs.');
    }

    final tempDir = await _getTempDir();
    final dateFormatted = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final backupFile = File('${tempDir.path}/gamestats_backup_$dateFormatted.zip');
    await backupFile.writeAsBytes(zipBytes, flush: true);

    return backupFile;
  }

  /// Creates a backup archive and triggers the system share dialog.
  Future<void> exportAndShare() async {
    final backupFile = await createBackupArchive();
    await Share.shareXFiles(
      [XFile(backupFile.path, mimeType: 'application/zip')],
      subject: 'Game Stats Backup',
      text: 'Hier ist das Game Stats Datenbank-Backup.',
    );
  }

  /// Parses a selected backup file (.zip or .json) and prepares a preview.
  Future<BackupPreview> parseBackupFile(File file) async {
    final bytes = await file.readAsBytes();
    final ext = p.extension(file.path).toLowerCase();

    Map<String, dynamic> rawJson;
    Directory? tempImagesDir;
    int imagesCount = 0;

    if (ext == '.json') {
      final jsonString = utf8.decode(bytes);
      rawJson = jsonDecode(jsonString) as Map<String, dynamic>;
    } else {
      // Decode ZIP archive
      final archive = ZipDecoder().decodeBytes(bytes);
      final dataEntry = archive.findFile('data.json');
      if (dataEntry == null) {
        throw Exception('Ungültige Backup-Datei: "data.json" nicht im Archiv gefunden.');
      }

      final jsonString = utf8.decode(dataEntry.content as List<int>);
      rawJson = jsonDecode(jsonString) as Map<String, dynamic>;

      // Extract images to temporary directory for inspection & import
      final tempDir = await _getTempDir();
      final extractFolder = Directory('${tempDir.path}/backup_extract_${DateTime.now().millisecondsSinceEpoch}');
      await extractFolder.create(recursive: true);
      tempImagesDir = extractFolder;

      for (final entry in archive) {
        if (entry.isFile && entry.name.startsWith('images/')) {
          final outFile = File('${extractFolder.path}/${entry.name}');
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(entry.content as List<int>);
          imagesCount++;
        }
      }
    }

    final version = rawJson['version'] as int? ?? 1;
    final exportedAtStr = rawJson['exportedAt'] as String?;
    final exportedAt = exportedAtStr != null ? DateTime.tryParse(exportedAtStr) : null;
    final gamesList = (rawJson['games'] as List<dynamic>?) ?? [];
    final playersList = (rawJson['players'] as List<dynamic>?) ?? [];
    final matchesList = (rawJson['matches'] as List<dynamic>?) ?? [];

    return BackupPreview(
      version: version,
      exportedAt: exportedAt,
      gamesCount: gamesList.length,
      playersCount: playersList.length,
      matchesCount: matchesList.length,
      imagesCount: imagesCount,
      rawJson: rawJson,
      tempImagesDir: tempImagesDir,
    );
  }

  /// Imports and applies the parsed backup data into Isar.
  /// [overwrite] : If true, clears existing data first. If false, merges new records.
  Future<void> applyBackup(BackupPreview preview, {required bool overwrite}) async {
    final rawJson = preview.rawJson;
    final gamesData = (rawJson['games'] as List<dynamic>?) ?? [];
    final playersData = (rawJson['players'] as List<dynamic>?) ?? [];
    final matchesData = (rawJson['matches'] as List<dynamic>?) ?? [];

    final appDocDir = await _getDocDir();
    final imagesDir = Directory('${appDocDir.path}/app_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Helper to copy an extracted image to permanent documents storage
    String? resolveImportedImage(String? relativePath) {
      if (relativePath == null || relativePath.isEmpty || preview.tempImagesDir == null) {
        return null;
      }
      final srcFile = File('${preview.tempImagesDir!.path}/$relativePath');
      if (!srcFile.existsSync()) return null;

      final permanentName = 'imported_${DateTime.now().microsecondsSinceEpoch}_${p.basename(srcFile.path)}';
      final destPath = '${imagesDir.path}/$permanentName';
      srcFile.copySync(destPath);
      return destPath;
    }

    if (overwrite) {
      await _db.clearAllData();
    }

    // 1. Process Games
    final existingGames = await _db.getAllGames();
    final gameMap = <String, Game>{};
    for (final g in existingGames) {
      gameMap[g.name.toLowerCase().trim()] = g;
    }

    for (final gData in gamesData) {
      final map = gData as Map<String, dynamic>;
      final name = (map['name'] as String? ?? '').trim();
      if (name.isEmpty) continue;

      final key = name.toLowerCase();
      final imagePath = resolveImportedImage(map['image'] as String?);

      if (gameMap.containsKey(key)) {
        final existing = gameMap[key]!;
        if (imagePath != null && (existing.imagePath == null || existing.imagePath!.isEmpty)) {
          await _db.updateGameImage(existing, imagePath);
        }
      } else {
        final newGame = Game()
          ..name = name
          ..imagePath = imagePath;
        final id = await _db.saveGame(newGame);
        newGame.id = id;
        gameMap[key] = newGame;
      }
    }

    // 2. Process Players
    final existingPlayers = await _db.getAllPlayers();
    final playerMap = <String, Player>{};
    for (final pl in existingPlayers) {
      playerMap[pl.name.toLowerCase().trim()] = pl;
    }

    for (final pData in playersData) {
      final map = pData as Map<String, dynamic>;
      final name = (map['name'] as String? ?? '').trim();
      if (name.isEmpty) continue;

      final key = name.toLowerCase();
      final imagePath = resolveImportedImage(map['image'] as String?);

      if (playerMap.containsKey(key)) {
        final existing = playerMap[key]!;
        if (imagePath != null && (existing.imagePath == null || existing.imagePath!.isEmpty)) {
          await _db.updatePlayerProfile(existing, existing.name, imagePath);
        }
      } else {
        final newPlayer = Player()
          ..name = name
          ..imagePath = imagePath;
        final id = await _db.savePlayer(newPlayer);
        newPlayer.id = id;
        playerMap[key] = newPlayer;
      }
    }

    // 3. Process Matches
    final existingMatches = await _db.getAllMatchRecords();

    for (final mData in matchesData) {
      final map = mData as Map<String, dynamic>;
      final gameName = (map['gameName'] as String? ?? '').trim();
      final dateStr = map['date'] as String?;
      if (gameName.isEmpty || dateStr == null) continue;

      final matchDate = DateTime.tryParse(dateStr) ?? DateTime.now();
      final numberOfPlayers = map['numberOfPlayers'] as int? ?? 1;
      final latitude = (map['latitude'] as num?)?.toDouble();
      final longitude = (map['longitude'] as num?)?.toDouble();

      // Check duplicate if merging
      if (!overwrite) {
        final isDuplicate = existingMatches.any((em) =>
            em.game.value?.name.toLowerCase().trim() == gameName.toLowerCase() &&
            em.date.difference(matchDate).inMinutes.abs() < 2);
        if (isDuplicate) {
          continue;
        }
      }

      // Ensure Game exists
      var game = gameMap[gameName.toLowerCase()];
      if (game == null) {
        final newGame = Game()..name = gameName;
        final id = await _db.saveGame(newGame);
        newGame.id = id;
        gameMap[gameName.toLowerCase()] = newGame;
        game = newGame;
      }

      // Resolve match images
      final singleImagePath = resolveImportedImage(map['image'] as String?);
      final rawPaths = (map['imagePaths'] as List<dynamic>?) ?? [];
      final resolvedPaths = <String>[];
      for (final rp in rawPaths) {
        final res = resolveImportedImage(rp as String?);
        if (res != null) resolvedPaths.add(res);
      }
      if (singleImagePath != null && !resolvedPaths.contains(singleImagePath)) {
        resolvedPaths.insert(0, singleImagePath);
      }

      // Resolve player scores
      final scoresData = (map['playerScores'] as List<dynamic>?) ?? [];
      final playerScores = <PlayerScore>[];

      for (final sData in scoresData) {
        final sMap = sData as Map<String, dynamic>;
        final pName = (sMap['playerName'] as String? ?? '').trim();
        if (pName.isEmpty) continue;

        // Ensure Player exists
        var player = playerMap[pName.toLowerCase()];
        if (player == null) {
          final newPlayer = Player()..name = pName;
          final pId = await _db.savePlayer(newPlayer);
          newPlayer.id = pId;
          playerMap[pName.toLowerCase()] = newPlayer;
          player = newPlayer;
        }

        final scoreEntry = PlayerScore()
          ..playerId = player.id
          ..playerName = player.name
          ..placement = sMap['placement'] as int? ?? 1
          ..score = sMap['score'] as int?;

        playerScores.add(scoreEntry);
      }

      final matchRecord = MatchRecord()
        ..date = matchDate
        ..numberOfPlayers = numberOfPlayers > 0 ? numberOfPlayers : playerScores.length
        ..imagePath = singleImagePath
        ..imagePaths = resolvedPaths
        ..latitude = latitude
        ..longitude = longitude
        ..playerScores = playerScores;

      matchRecord.game.value = game;
      await _db.saveMatchRecord(matchRecord);
    }

    // Clean up temporary extraction folder
    try {
      if (preview.tempImagesDir != null && await preview.tempImagesDir!.exists()) {
        await preview.tempImagesDir!.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Warning: Could not delete temp dir: $e');
    }
  }
}
