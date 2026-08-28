import 'package:isar/isar.dart';

part 'game.g.dart';

@collection
class Game {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? imagePath;
}
