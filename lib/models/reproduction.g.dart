// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reproduction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReproductionAdapter extends TypeAdapter<Reproduction> {
  @override
  final int typeId = 5;

  @override
  Reproduction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reproduction(
      id: fields[0] as String,
      animalId: fields[1] as String,
      dateEvenement: fields[2] as DateTime,
      typeEvenement: fields[3] as String,
      notes: fields[4] as String?,
      datePrevueMiseBas: fields[5] as DateTime?,
      partenaireId: fields[6] as String?,
      succes: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Reproduction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.animalId)
      ..writeByte(2)
      ..write(obj.dateEvenement)
      ..writeByte(3)
      ..write(obj.typeEvenement)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.datePrevueMiseBas)
      ..writeByte(6)
      ..write(obj.partenaireId)
      ..writeByte(7)
      ..write(obj.succes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReproductionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
