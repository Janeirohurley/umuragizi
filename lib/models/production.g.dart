// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductionAdapter extends TypeAdapter<Production> {
  @override
  final int typeId = 7;

  @override
  Production read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Production(
      id: fields[0] as String,
      animalId: fields[1] as String,
      date: fields[2] as DateTime,
      type: fields[3] as String,
      quantite: fields[4] as double,
      unite: fields[5] as String,
      prixUnitaire: fields[6] as double?,
      notes: fields[7] as String?,
      transactionId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Production obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.animalId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.quantite)
      ..writeByte(5)
      ..write(obj.unite)
      ..writeByte(6)
      ..write(obj.prixUnitaire)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.transactionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
