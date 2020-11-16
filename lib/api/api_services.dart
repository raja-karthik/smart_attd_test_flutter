import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_first_flutterapp/model/user_model.dart';

class APIService {
  Future<LoginModel> loginUser(String email, String password) async {
    final http.Response response = await http.post(
      'https://reqres.in/api/login',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 400) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return LoginModel.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to load Data');
    }
  }
}
