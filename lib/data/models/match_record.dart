import 'package:isar/isar.dart';
import 'game.dart';

part 'match_record.g.dart';

@embedded
class PlayerScore {
  int? playerId;
  String? playerName;
  int placement = 1;
  int? score;
}

@collection
class MatchRecord {
  Id id = Isar.autoIncrement;

  final game = IsarLink<Game>();

  late DateTime date;
  late int numberOfPlayers;
  
  String? imagePath; // Keep for backwards compatibility
  List<String> imagePaths = [];
  
  List<PlayerScore> playerScores = [];

  double? latitude;
  double? longitude;
}
