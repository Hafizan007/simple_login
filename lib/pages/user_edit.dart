import 'dart:convert';
import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:jada/providers/user_provider.dart';
import 'package:jada/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class EditUser extends StatefulWidget {
  EditUser({Key key, this.iduser}) : super(key: key);
  final String iduser;
  bool isloading = false;

  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final formKey = new GlobalKey<FormState>();
  TextEditingController _textCtrlTlp = TextEditingController();
  TextEditingController _textname = TextEditingController();

  String _username, _name, _confirmPassword;

  Future<void> getdata() async {
    final user = await Provider.of<UserProvider>(context, listen: false).user;
    var url = 'http://api.ngodink.com/users/' + widget.iduser;
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${user.token}',
      },
    );
    print(url);
    print(response.body.toString());

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        _username = jsonResponse['username'];
        _name = jsonResponse['name'];
        _textCtrlTlp.text = jsonResponse['username'];
        _textname.text = jsonResponse['name'];
      });
      print(_name);
    }
  }

  Future<void> updatedata() async {
    final user = await Provider.of<UserProvider>(context, listen: false).user;
    var url = 'http://api.ngodink.com/users/' + widget.iduser;
    var mydata = {
      "name": _name,
      "username": _username,
      "password": _confirmPassword,
    };
    final response = await http.put(
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
  void initState() {
    getdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final usernameField = TextFormField(
      initialValue: _username != null ? _username.toString() : 'sssss',
      autofocus: false,
      onSaved: (value) => _username = value,
      decoration:
          buildInputDecoration("Confirm password", Icons.people_alt_rounded),
    );

    final passwordField = TextFormField(
      autofocus: false,
      initialValue: _name,
      onSaved: (value) => _name = value,
      decoration:
          buildInputDecoration("Confirm password", Icons.people_alt_rounded),
    );

    final confirmPassword = TextFormField(
      autofocus: false,
      validator: (value) => value.isEmpty ? "Your password is required" : null,
      onSaved: (value) => _confirmPassword = value,
      obscureText: true,
      decoration: buildInputDecoration("Confirm password", Icons.lock),
    );
    var doRegister = () {
      final form = formKey.currentState;
      if (form.validate()) {
        form.save();
        print(_username);
        updatedata();
        // auth.register(_username, _name, _confirmPassword).then((response) {
        //   print(response);
        //   print(response['status']);
        //   if (response['status']) {
        //     User user = response['data'];
        //     print('sampai');
        //     Provider.of<UserProvider>(context, listen: false).setUser(user);

        //     Navigator.pushReplacementNamed(context, '/dashboard');
        //   }
        //   // else {
        //   //   Flushbar(
        //   //     title: "Registration Failed",
        //   //     message: response.toString(),
        //   //     duration: Duration(seconds: 10),
        //   //   ).show(context);
        //   // }
        // });
      } else {
        Flushbar(
          title: "Invalid form",
          message: "Please Complete the form properly",
          duration: Duration(seconds: 10),
        ).show(context);
      }
    };
    return Scaffold(
      appBar: new AppBar(
        title: Text('Update Data'),
      ),
      body: Container(
        child: Container(
          padding: EdgeInsets.all(40.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.0),
                label("Username"),
                TextFormField(
                  controller: _textCtrlTlp,
                  style: TextStyle(fontSize: 16),
                  decoration:
                      buildInputDecoration("Confirm password", Icons.people),
                  keyboardType: TextInputType.text,
                  onSaved: (value) => _username = value,
                ),
                SizedBox(height: 15.0),
                label("Name"),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _textname,
                  style: TextStyle(fontSize: 16),
                  decoration:
                      buildInputDecoration("Confirm password", Icons.people),
                  keyboardType: TextInputType.text,
                  onSaved: (value) => _name = value,
                ),
                SizedBox(height: 15.0),
                label("Password"),
                SizedBox(height: 10.0),
                confirmPassword,
                SizedBox(height: 20.0),
                longButtons('Submit', doRegister)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
