import 'package:json_annotation/json_annotation.dart';
// import 'package:minsk8/import.dart';

part 'message.g.dart';

@JsonSerializable()
class MessageModel {
  MessageModel({
    this.id,
    this.text,
    this.author,
    this.isRead,
    this.createdAt,
  });

  final String id;
  final String text;
  final MessageAuthor author;
  final bool isRead;
  final DateTime createdAt;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}

enum MessageAuthor {
  @JsonValue('unit_owner')
  unitOwner,
  companion,
}

// TODO: прикрутить flutter_svg + https://www.google.com/get/noto/help/emoji/
