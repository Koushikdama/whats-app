import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Contacts {
  String name;
  String description;
  String profilepic;
  String phonenumber;
  String uid;
  Contacts({
    required this.name,
    required this.description,
    required this.profilepic,
    required this.phonenumber,
    required this.uid,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'profilepic': profilepic,
      'phonenumber': phonenumber,
      'uid': uid,
    };
  }

  factory Contacts.fromMap(Map<String, dynamic> map) {
    return Contacts(
      name: (map['name'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      profilepic: (map['profilepic'] ?? '') as String,
      phonenumber: (map['phonenumber'] ?? '') as String,
      uid: (map['uid'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Contacts.fromJson(String source) =>
      Contacts.fromMap(json.decode(source) as Map<String, dynamic>);

  Contacts copyWith({
    String? name,
    String? description,
    String? profilepic,
    String? phonenumber,
    String? uid,
  }) {
    return Contacts(
      name: name ?? this.name,
      description: description ?? this.description,
      profilepic: profilepic ?? this.profilepic,
      phonenumber: phonenumber ?? this.phonenumber,
      uid: uid ?? this.uid,
    );
  }

  @override
  String toString() {
    return 'Contacts(name: $name, description: $description, profilepic: $profilepic, phonenumber: $phonenumber, uid: $uid)';
  }

  @override
  bool operator ==(covariant Contacts other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.description == description &&
        other.profilepic == profilepic &&
        other.phonenumber == phonenumber &&
        other.uid == uid;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        description.hashCode ^
        profilepic.hashCode ^
        phonenumber.hashCode ^
        uid.hashCode;
  }
}
