import 'package:isar/isar.dart';

part 'player.g.dart';

@collection
class Player {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;
  
  String? imagePath;

  bool isMe = false;

  String? linkedUserId;

  String? friendCode;
}
