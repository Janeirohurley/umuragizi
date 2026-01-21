// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alimentation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlimentationAdapter extends TypeAdapter<Alimentation> {
  @override
  final int typeId = 1;

  @override
  Alimentation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alimentation(
      id: fields[0] as String,
      animalId: fields[1] as String,
      date: fields[2] as DateTime,
      typeAliment: fields[3] as String,
      quantite: fields[4] as double,
      unite: fields[5] as String,
      notes: fields[6] as String?,
      prixUnitaire: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Alimentation obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.animalId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.typeAliment)
      ..writeByte(4)
      ..write(obj.quantite)
      ..writeByte(5)
      ..write(obj.unite)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.prixUnitaire);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlimentationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
