class User {
  int userId;
  String name;
  String username;
  // String phone;
  // String type;
  String token;
  // String renewalToken;

  User({this.userId, this.name, this.username, this.token});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
      userId: responseData['data']['id'],
      name: responseData['data']['name'],
      username: responseData['data']['username'],
      token: responseData['token'],
    );
  }
}

class AuthUser {
  String token;

  AuthUser({this.token});

  factory AuthUser.fromJson(Map<String, dynamic> responseData) {
    return AuthUser(
      token: responseData['token'],
    );
  }
}
