class LoginModel {
  final String token;
  final String error;

  LoginModel({this.token, this.error});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      token: json['token'] != null ? json['token'] : "",
      error: json['error'] != null ? json['error'] : "",
    );
  }
}

class RegisterModel {
  final int id;
  final String token;
  final String error;

  RegisterModel({this.id, this.token, this.error});

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      id: json['id'] != null ? json['id'] : 0,
      token: json['token'] != null ? json['token'] : "",
      error: json['error'] != null ? json['error'] : "",
    );
  }
}
