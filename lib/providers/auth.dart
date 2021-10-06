import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jada/domain/user.dart';
import 'package:jada/util/app_url.dart';
import 'package:jada/util/shared_preference.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.NotLoggedIn;
  Status _registeredInStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredInStatus => _registeredInStatus;

  Future<Map<String, dynamic>> login(String email, String password) async {
    var result;

    final Map<String, dynamic> loginData = {
      "username": email,
      "password": password,
      "grant_type": "password",
      "client_id": "2",
      "client_secret": "6TdLty3vtpUZElpFo5KsN949D6tzdWJDzi19msdP"
    };
    print('aku ${loginData}');

    _loggedInStatus = Status.Authenticating;
    notifyListeners();

    Response response = await post(
      AppUrl.login,
      body: json.encode(loginData),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      Response response2 = await get(AppUrl.getuser, headers: {
        HttpHeaders.authorizationHeader:
            'Bearer ${responseData['access_token']}'
      });

      if (response2.statusCode == 200) {
        final Map<String, dynamic> responseData2 = json.decode(response2.body);
        print(responseData2);
        var custom_res = {
          'data': responseData2,
          'token': responseData['access_token']
        };
        User authUser = User.fromJson(custom_res);

        UserPreferences().saveUser(authUser);

        _loggedInStatus = Status.LoggedIn;
        notifyListeners();

        result = {'status': true, 'message': 'Successful', 'user': authUser};
      }
      // var userData = responseData['data'];

    } else {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
      result = {
        'status': false,
        'message': json.decode(response.body)['error']
      };
    }
    return result;
  }

  Future<Map<String, dynamic>> register(
      String email, String password, String passwordConfirmation) async {
    final Map<String, dynamic> registrationData = {
      "grant_type": "password",
      "client_id": "2",
      "client_secret": "6TdLty3vtpUZElpFo5KsN949D6tzdWJDzi19msdP",
      "username": email,
      "name": password,
      "password": passwordConfirmation
    };
    return await post(AppUrl.register,
            body: json.encode(registrationData),
            headers: {'Content-Type': 'application/json'})
        .then(onValue)
        .catchError(onError);
  }

  static Future<FutureOr> onValue(Response response) async {
    var result;
    final Map<String, dynamic> responseData = json.decode(response.body);

    print(response.statusCode);
    if (response.statusCode == 200) {
      var userData = responseData['data'];

      User authUser = User.fromJson(responseData);

      UserPreferences().saveUser(authUser);
      result = {
        'status': true,
        'message': 'Successfully registered',
        'data': authUser
      };
    } else {
//      if (response.statusCode == 401) Get.toNamed("/login");
      result = {
        'status': false,
        'message': 'Registration failed',
        'data': responseData
      };
    }

    return result;
  }

  static onError(error) {
    print("the error is $error.detail");
    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
  }
}
