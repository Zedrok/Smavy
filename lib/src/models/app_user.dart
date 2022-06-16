import 'dart:convert';

AppUser appUserFromJson(String str) => AppUser.fromJson(json.decode(str));

String appUserToJson(AppUser data) => json.encode(data.toJson());

class AppUser {
  String? id;
  String? username;
  String? email;
  String? password;
  String? image;

  AppUser({
    this.id,
    this.username,
    this.email,
    this.password,
    this.image,
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

  /*Map<String, dynamic> fromSnapshot(snapshot):
        id = snapshot.data()["id"],
        username = snapshot.data()["username"],
        email = snapshot.data()["email"],
        password = snapshot.data()["password"];*/
}
