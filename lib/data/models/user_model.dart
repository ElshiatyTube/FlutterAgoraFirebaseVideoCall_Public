class UserModel{
  late String id;
  late String name;
  late String email;
  late String avatar;
  late bool online;
  late num lastOnline;
  bool? busy;


  UserModel({required this.name, required this.avatar});

  UserModel.resister({required this.name, required this.id,required this.email,required this.avatar,required this.busy});

  UserModel.comment({required this.id,required this.name, required this.avatar});

  UserModel.fromJsonMap({required Map<String, dynamic> map,required String uId}){
    id = uId;
    name = map["name"];
    email = map["email"];
    avatar = map["avatar"];
    busy = map["busy"];
    lastOnline = map["lastOnline"]??0;
    online = map["online"]??false;
  }

 factory UserModel.fromUserCommentJsonMap({required Map<String, dynamic> map}) {
    return UserModel.comment(
      id: map["uId"],
      name: map["name"],
      avatar: map["avatar"],
    );
  }

  Map<String,dynamic> toUserCommentMap(){
    return {
      "uId": id,
      "name": name,
      "avatar": avatar,
    };
  }

  Map<String,dynamic> toMap(){
    return {
      "uId": id,
      "name": name,
      "email": email,
      "avatar": avatar,
      "busy": false,
      "online": true,
      "lastOnline": DateTime.now().millisecondsSinceEpoch,
    };
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