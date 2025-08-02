// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 0;

  @override
  Item read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Item(
      id: fields[0] as String,
      photoPath: fields[1] as String?,
      weight: fields[2] as double,
      price: fields[3] as double,
      inStock: fields[4] as bool,
      sellerName: fields[5] as String,
      caliber: fields[6] as String,
      stamp: fields[7] as String,
      details: fields[8] as String,
      nationalCardNumber: fields[9] as String,
      signaturePageReference: fields[10] as String,
      sellerType: fields[11] as String,
      itemName: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.photoPath)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.inStock)
      ..writeByte(5)
      ..write(obj.sellerName)
      ..writeByte(6)
      ..write(obj.caliber)
      ..writeByte(7)
      ..write(obj.stamp)
      ..writeByte(8)
      ..write(obj.details)
      ..writeByte(9)
      ..write(obj.nationalCardNumber)
      ..writeByte(10)
      ..write(obj.signaturePageReference)
      ..writeByte(11)
      ..write(obj.sellerType)
      ..writeByte(12)
      ..write(obj.itemName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
