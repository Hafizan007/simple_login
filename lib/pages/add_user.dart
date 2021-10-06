import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:jada/providers/user_provider.dart';
import 'package:jada/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AddUser extends StatefulWidget {
  const AddUser({Key key}) : super(key: key);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final formKey = new GlobalKey<FormState>();

  String _username, _name, _password;
  Future<void> saveData(String name, String username, String password) async {
    final user = await Provider.of<UserProvider>(context, listen: false).user;
    var url = 'http://api.ngodink.com/users';
    var mydata = {
      "name": name,
      "username": username,
      "password": password,
    };
    final response = await http.post(
      url,
      body: mydata,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${user.token}',
      },
    );
    print(url);
    print(response.body.toString());

    if (response.statusCode == 200) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usernameField = TextFormField(
      autofocus: false,
      onSaved: (value) => _username = value,
      decoration: buildInputDecoration("Name", Icons.people_alt_rounded),
    );

    final passwordField = TextFormField(
      autofocus: false,
      onSaved: (value) => _name = value,
      decoration: buildInputDecoration("Username", Icons.people_alt_rounded),
    );

    final confirmPassword = TextFormField(
      autofocus: false,
      validator: (value) => value.isEmpty ? "Your password is required" : null,
      onSaved: (value) => _password = value,
      obscureText: true,
      decoration: buildInputDecoration("password", Icons.lock),
    );

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(" Registering ... Please wait")
      ],
    );

    var doSave = () {
      final form = formKey.currentState;
      if (form.validate()) {
        form.save();
        print(_username);

        saveData(_name, _username, _password);
      } else {
        Flushbar(
          title: "Invalid form",
          message: "Please Complete the form properly",
          duration: Duration(seconds: 10),
        ).show(context);
      }
    };

    return SafeArea(
      child: Scaffold(
        appBar: new AppBar(
          title: Text('Create User'),
        ),
        body: Container(
          padding: EdgeInsets.all(40.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.0),
                label("Username"),
                SizedBox(height: 5.0),
                usernameField,
                SizedBox(height: 15.0),
                label("Name"),
                SizedBox(height: 10.0),
                passwordField,
                SizedBox(height: 15.0),
                label("Password"),
                SizedBox(height: 10.0),
                confirmPassword,
                SizedBox(height: 20.0),
                longButtons("Create User", doSave),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
