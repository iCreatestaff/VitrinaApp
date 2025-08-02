import 'package:hive_flutter/hive_flutter.dart';
import '../models/item.dart';
import '../models/sell.dart';
import '../models/history_entry.dart';

class HiveService {
  static const String itemBoxName = 'items';
  static const String sellBoxName = 'sales';
  static const String historyBoxName = 'history';

  static Future<void> initHive() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ItemAdapter());
    Hive.registerAdapter(SellAdapter());
    Hive.registerAdapter(HistoryEntryAdapter());

    await Hive.openBox<Item>(itemBoxName);
    await Hive.openBox<Sell>(sellBoxName);
    await Hive.openBox<HistoryEntry>(historyBoxName);
  }

  static Box<Item> getItemBox() => Hive.box<Item>(itemBoxName);
  static Box<Sell> getSellBox() => Hive.box<Sell>(sellBoxName);
  static Box<HistoryEntry> getHistoryBox() =>
      Hive.box<HistoryEntry>(historyBoxName);
}
