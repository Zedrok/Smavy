import 'dart:convert';

AppUser appUserFromJson(String str) => AppUser.fromJson(json.decode(str));

String appUserToJson(AppUser data) => json.encode(data.toJson());

class AppUser {
  String id;
  String username;
  String email;
  String password;
  String image;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.image,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        password: json["password"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "email": email,
        "image": image,
      };
}
