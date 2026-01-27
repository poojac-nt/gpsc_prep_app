// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prelims_test_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrelimsTestProgressAdapter extends TypeAdapter<PrelimsTestProgress> {
  @override
  final int typeId = 3;

  @override
  PrelimsTestProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrelimsTestProgress(
      userId: fields[0] as int,
      testId: fields[1] as int,
      languageCode: fields[2] as String,
      currentQuestionIndex: fields[3] as int,
      selectedOptions: (fields[4] as List).cast<String?>(),
      answeredStatus: (fields[5] as List).cast<bool>(),
      remainingTimeInSeconds: fields[6] as int,
      savedAt: fields[7] as String,
      totalQuestions: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PrelimsTestProgress obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.testId)
      ..writeByte(2)
      ..write(obj.languageCode)
      ..writeByte(3)
      ..write(obj.currentQuestionIndex)
      ..writeByte(4)
      ..write(obj.selectedOptions)
      ..writeByte(5)
      ..write(obj.answeredStatus)
      ..writeByte(6)
      ..write(obj.remainingTimeInSeconds)
      ..writeByte(7)
      ..write(obj.savedAt)
      ..writeByte(8)
      ..write(obj.totalQuestions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrelimsTestProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
