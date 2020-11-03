import 'package:json_annotation/json_annotation.dart';
import 'package:minsk8/import.dart';

part 'win.g.dart';

@JsonSerializable()
class WinModel {
  WinModel({
    this.member,
    this.createdAt,
  });

  @JsonKey(nullable: true) // надо для profile.member.bids.win
  final MemberModel member;
  final DateTime createdAt;

  factory WinModel.fromJson(Map<String, dynamic> json) =>
      _$WinModelFromJson(json);

  Map<String, dynamic> toJson() => _$WinModelToJson(this);
}
