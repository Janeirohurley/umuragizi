// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimalAdapter extends TypeAdapter<Animal> {
  @override
  final int typeId = 0;

  @override
  Animal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Animal(
      id: fields[0] as String,
      nom: fields[1] as String,
      espece: fields[2] as String,
      race: fields[3] as String,
      sexe: fields[4] as String,
      dateNaissance: fields[5] as DateTime,
      photoPath: fields[6] as String?,
      identifiant: fields[7] as String,
      dateAjout: fields[8] as DateTime,
      notes: fields[9] as String?,
      photoBase64: fields[10] as String?,
      mereId: fields[11] as String?,
      prixAchat: fields[12] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Animal obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.espece)
      ..writeByte(3)
      ..write(obj.race)
      ..writeByte(4)
      ..write(obj.sexe)
      ..writeByte(5)
      ..write(obj.dateNaissance)
      ..writeByte(6)
      ..write(obj.photoPath)
      ..writeByte(7)
      ..write(obj.identifiant)
      ..writeByte(8)
      ..write(obj.dateAjout)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.photoBase64)
      ..writeByte(11)
      ..write(obj.mereId)
      ..writeByte(12)
      ..write(obj.prixAchat);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
