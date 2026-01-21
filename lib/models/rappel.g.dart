// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rappel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RappelAdapter extends TypeAdapter<Rappel> {
  @override
  final int typeId = 4;

  @override
  Rappel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Rappel(
      id: fields[0] as String,
      animalId: fields[1] as String,
      titre: fields[2] as String,
      description: fields[3] as String,
      dateRappel: fields[4] as DateTime,
      type: fields[5] as String,
      estComplete: fields[6] as bool,
      dateCompletion: fields[7] as DateTime?,
      recurrent: fields[8] as bool,
      intervalleJours: fields[9] as int?,
      intervalleHeures: fields[10] as int?,
      dateFin: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Rappel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.animalId)
      ..writeByte(2)
      ..write(obj.titre)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.dateRappel)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.estComplete)
      ..writeByte(7)
      ..write(obj.dateCompletion)
      ..writeByte(8)
      ..write(obj.recurrent)
      ..writeByte(9)
      ..write(obj.intervalleJours)
      ..writeByte(10)
      ..write(obj.intervalleHeures)
      ..writeByte(11)
      ..write(obj.dateFin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RappelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
