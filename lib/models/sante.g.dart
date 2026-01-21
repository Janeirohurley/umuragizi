// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sante.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SanteAdapter extends TypeAdapter<Sante> {
  @override
  final int typeId = 2;

  @override
  Sante read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sante(
      id: fields[0] as String,
      animalId: fields[1] as String,
      date: fields[2] as DateTime,
      type: fields[3] as String,
      description: fields[4] as String,
      medicament: fields[5] as String?,
      veterinaire: fields[6] as String?,
      notes: fields[7] as String?,
      cout: fields[8] as double?,
      estPaye: fields[9] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, Sante obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.animalId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.medicament)
      ..writeByte(6)
      ..write(obj.veterinaire)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.cout)
      ..writeByte(9)
      ..write(obj.estPaye);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SanteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CroissanceAdapter extends TypeAdapter<Croissance> {
  @override
  final int typeId = 3;

  @override
  Croissance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Croissance(
      id: fields[0] as String,
      animalId: fields[1] as String,
      date: fields[2] as DateTime,
      poids: fields[3] as double,
      taille: fields[4] as double?,
      etatPhysique: fields[5] as String?,
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Croissance obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.animalId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.poids)
      ..writeByte(4)
      ..write(obj.taille)
      ..writeByte(5)
      ..write(obj.etatPhysique)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CroissanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
