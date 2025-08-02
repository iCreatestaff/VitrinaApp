import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? photoPath;

  @HiveField(2)
  double weight;

  @HiveField(3)
  double price;

  @HiveField(4)
  bool inStock;

  @HiveField(5)
  String sellerName;

  @HiveField(6)
  String caliber;

  @HiveField(7)
  String stamp;

  @HiveField(8)
  String details;
  @HiveField(9)
  String nationalCardNumber;

  @HiveField(10)
  String signaturePageReference;

  @HiveField(11)
  String sellerType;

  @HiveField(12)
  String itemName;

  Item(
      {required this.id,
      this.photoPath,
      required this.weight,
      required this.price,
      required this.inStock,
      required this.sellerName,
      required this.caliber,
      required this.stamp,
      required this.details,
      required this.nationalCardNumber,
      required this.signaturePageReference,
      required this.sellerType,
      required this.itemName});
}
