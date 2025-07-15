// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TestResultModelAdapter extends TypeAdapter<TestResultModel> {
  @override
  final int typeId = 1;

  @override
  TestResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestResultModel(
      userId: fields[0] as int,
      testId: fields[1] as int,
      totalQuestions: fields[2] as int,
      correctAnswers: fields[3] as int,
      inCorrectAnswers: fields[4] as int,
      attemptedQuestions: fields[5] as int,
      notAttemptedQuestions: fields[6] as int,
      score: fields[7] as double,
      timeTaken: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TestResultModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.testId)
      ..writeByte(2)
      ..write(obj.totalQuestions)
      ..writeByte(3)
      ..write(obj.correctAnswers)
      ..writeByte(4)
      ..write(obj.inCorrectAnswers)
      ..writeByte(5)
      ..write(obj.attemptedQuestions)
      ..writeByte(6)
      ..write(obj.notAttemptedQuestions)
      ..writeByte(7)
      ..write(obj.score)
      ..writeByte(8)
      ..write(obj.timeTaken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestResultModel _$TestResultModelFromJson(Map<String, dynamic> json) =>
    TestResultModel(
      userId: (json['user_id'] as num).toInt(),
      testId: (json['test_id'] as num).toInt(),
      totalQuestions: (json['total_questions'] as num).toInt(),
      correctAnswers: (json['correct_answers'] as num).toInt(),
      inCorrectAnswers: (json['incorrect_answers'] as num).toInt(),
      attemptedQuestions: (json['attempted_questions'] as num).toInt(),
      notAttemptedQuestions: (json['not_attempted_questions'] as num).toInt(),
      score: (json['score'] as num).toDouble(),
      timeTaken: (json['time_taken'] as num).toInt(),
    );

Map<String, dynamic> _$TestResultModelToJson(TestResultModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'test_id': instance.testId,
      'total_questions': instance.totalQuestions,
      'correct_answers': instance.correctAnswers,
      'incorrect_answers': instance.inCorrectAnswers,
      'attempted_questions': instance.attemptedQuestions,
      'not_attempted_questions': instance.notAttemptedQuestions,
      'score': instance.score,
      'time_taken': instance.timeTaken,
    };
