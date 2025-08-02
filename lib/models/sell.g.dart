// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sell.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SellAdapter extends TypeAdapter<Sell> {
  @override
  final int typeId = 2;

  @override
  Sell read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sell(
      id: fields[0] as String,
      itemIds: (fields[1] as List).cast<String>(),
      date: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Sell obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemIds)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
