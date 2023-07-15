// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user1.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User1 _$User1FromJson(Map<String, dynamic> json) => User1(
      json['age'] as int,
      User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$User1ToJson(User1 instance) => <String, dynamic>{
      'age': instance.age,
      'user': instance.user,
    };
