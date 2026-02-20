// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detailed_test_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetailedTestResultAdapter extends TypeAdapter<DetailedTestResult> {
  @override
  final int typeId = 2;

  @override
  DetailedTestResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetailedTestResult(
      userId: fields[0] as int,
      testId: fields[1] as int,
      questionId: fields[2] as int,
      isCorrect: fields[3] as bool,
      selectedOption: fields[4] as String?,
      attemptNo: fields[5] as int,
      timeSpent: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DetailedTestResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.testId)
      ..writeByte(2)
      ..write(obj.questionId)
      ..writeByte(3)
      ..write(obj.isCorrect)
      ..writeByte(4)
      ..write(obj.selectedOption)
      ..writeByte(5)
      ..write(obj.attemptNo)
      ..writeByte(6)
      ..write(obj.timeSpent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetailedTestResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetailedTestResult _$DetailedTestResultFromJson(Map<String, dynamic> json) =>
    DetailedTestResult(
      userId: (json['user_id'] as num).toInt(),
      testId: (json['test_id'] as num).toInt(),
      questionId: (json['question_id'] as num).toInt(),
      isCorrect: json['is_correct'] as bool,
      selectedOption: json['selected_option'] as String?,
      attemptNo: (json['attempt_no'] as num).toInt(),
      timeSpent: (json['time_spent'] as num).toInt(),
    );

Map<String, dynamic> _$DetailedTestResultToJson(DetailedTestResult instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'test_id': instance.testId,
      'question_id': instance.questionId,
      'is_correct': instance.isCorrect,
      'selected_option': instance.selectedOption,
      'attempt_no': instance.attemptNo,
      'time_spent': instance.timeSpent,
    };
