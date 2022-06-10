class UserModel{
  late String id;
  late String name;
  late String email;
  late String password;
  late String avatar;
  bool? busy;


  UserModel({required this.name, required this.avatar});

  UserModel.fromJsonMap({required Map<String, dynamic> map,required String uId}){
    id = uId;
    name = map["name"];
    email = map["email"];
    password = map["password"];
    avatar = map["avatar"];
    busy = map["busy"];
  }
}

class UserFcmTokenModel{
  late String uId, token;

  UserFcmTokenModel({required this.uId, required this.token});

  UserFcmTokenModel.fromJson(Map<String, dynamic> json) {
    uId = json['uId'];
    token = json['token'];
  }

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'token': token,
    };
  }
}