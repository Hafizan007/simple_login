import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jada/domain/user.dart';
import 'package:jada/pages/add_user.dart';
import 'package:jada/pages/user_edit.dart';
import 'package:jada/providers/user_provider.dart';
import 'package:jada/util/shared_preference.dart';
import 'package:provider/provider.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  List<Map> items = [];

  void autoLogIn() async {
    final user = await UserPreferences().getUser();
    if (user != null) {
      Provider.of<UserProvider>(context, listen: false).setUser(user);
      // Provider.of<Auth>(context).tryAutoLogin().then((_) {});
    }
    this.payment(user.token);

    // final String userId = prefs.getString('username');

    // if (userId != null) {
    //   setState(() {
    //     isLoggedIn = true;
    //     name = userId;
    //   });
    //   return;
    // }
  }

  Future<void> delete(String id, String token) async {
    print(token);
    final user = await Provider.of<UserProvider>(context, listen: false).user;
    var url = 'http://api.ngodink.com/users/' + id;
    final response = await http.delete(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${token}',
      },
    );
    print(url);
    print(response.body.toString());

    if (response.statusCode == 200) {
      print('sampai');
      payment(token);
    }
  }

  Future<void> payment(String token) async {
    // print(user.token);
    // User user = await Provider.of<UserProvider>(context).user;
    var url2 = 'http://api.ngodink.com/users';
    final response2 = await http.get(
      url2,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${token}',
      },
    );
    print('URL2 =>' + url2);
    print('RESS =>' + response2.body.toString());

    if (response2.statusCode == 200) {
      // var disc = jsonDecode(response.body);
      var jsonResponse = jsonDecode(response2.body);

      // print('REStest =>' + jsonResponse);
      setState(() {
        items = [];
        List<dynamic> coinList = jsonResponse;
        for (dynamic coin in coinList) {
          items.add({
            'id': coin['id'],
            'name': coin['name'],
            'username': coin['username'],
            'created_at': coin['created_at'],
            'updated_at': coin['updated_at'],
          });
        }
      });
      print("aku $items");

      // final result = payment.result;

    }
    // } catch (error) {
    //   // print('ERROR =>' + error);
    //   // throw (error);
    // }
    // setState(() {
    //   isloading1 = false;
    // });
  }

  @override
  void initState() {
    autoLogIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Page'),
        elevation: 0.1,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Name:${items[index]['name']}",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(" | Username: ${items[index]['username']}",
                            style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: new Icon(Icons.delete),
                                  onPressed: () {
                                    delete(items[index]['id'].toString(),
                                        user.token);
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => EditUser(
                                    //             iduser:
                                    //                 items[index]['id'].toString(),
                                    //           )),
                                    // ).then((value) {
                                    //   if (value) payment(user.token);
                                    // });
                                  },
                                ),
                                IconButton(
                                  icon: new Icon(Icons.edit),
                                  onPressed: () {
                                    // delete(
                                    //     items[index]['id'].toString(), user.token);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditUser(
                                                iduser: items[index]['id']
                                                    .toString(),
                                              )),
                                    ).then((value) {
                                      if (value) payment(user.token);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 30),
          RaisedButton(
            onPressed: () {
              UserPreferences().removeUser();
              Navigator.pushReplacementNamed(context, '/login');
              // autoLogIn();
              //             Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => EditUser(iduser: ,)),
              // );
            },
            child: Text("Logout"),
            color: Colors.lightBlueAccent,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddUser()))
              .then((value) => payment(user.token));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
