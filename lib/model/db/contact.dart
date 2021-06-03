// @dart=2.9

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

part 'contact.g.dart';

@JsonSerializable()
class Contact {
  Contact({@required this.name, @required this.address, int id});

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
  Map<String, dynamic> toJson() => _$ContactToJson(this);

  @JsonKey(ignore: true)
  int id;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'address')
  String address;
  @override
  bool operator ==(o) => o is Contact && o.name == name && o.address == address;
  @override
  int get hashCode => hash2(name.hashCode, address.hashCode);
}
