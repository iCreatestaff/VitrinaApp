import 'package:hive/hive.dart';

part 'sell.g.dart';

@HiveType(typeId: 2)
class Sell extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  List<String> itemIds;

  @HiveField(2)
  DateTime date;

  Sell({
    required this.id,
    required this.itemIds,
    required this.date,
  });
}
