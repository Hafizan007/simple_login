import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:jada/domain/user.dart';
import 'package:jada/providers/auth.dart';
import 'package:jada/providers/user_provider.dart';
import 'package:jada/util/validators.dart';
import 'package:jada/util/widgets.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = new GlobalKey<FormState>();

  String _username, _name, _confirmPassword;

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    final usernameField = TextFormField(
      autofocus: false,
      onSaved: (value) => _username = value,
      decoration:
          buildInputDecoration("Confirm password", Icons.people_alt_rounded),
    );

    final passwordField = TextFormField(
      autofocus: false,
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

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text(" Registering ... Please wait")
      ],
    );

    var doRegister = () {
      final form = formKey.currentState;
      if (form.validate()) {
        form.save();
        print(_username);

        auth.register(_username, _name, _confirmPassword).then((response) {
          print(response);
          print(response['status']);
          if (response['status']) {
            User user = response['data'];
            print('sampai');
            Provider.of<UserProvider>(context, listen: false).setUser(user);

            Navigator.pushReplacementNamed(context, '/dashboard');
          }
          // else {
          //   Flushbar(
          //     title: "Registration Failed",
          //     message: response.toString(),
          //     duration: Duration(seconds: 10),
          //   ).show(context);
          // }
        });
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
                auth.loggedInStatus == Status.Authenticating
                    ? loading
                    : longButtons("Login", doRegister),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
