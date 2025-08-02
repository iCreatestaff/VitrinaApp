import 'package:hive/hive.dart';

part 'history_entry.g.dart';

@HiveType(typeId: 1)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String operation; // add, modify, sell, delete

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String itemId;

  HistoryEntry({
    required this.id,
    required this.operation,
    required this.date,
    required this.itemId,
  });
}
