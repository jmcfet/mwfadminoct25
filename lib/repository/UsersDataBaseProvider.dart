import 'package:adminui/models/PlayersinfoandBookedDate.dart';
import 'package:adminui/models/UsersResponse.dart';
import 'package:adminui/models/BookedDatesResponse.dart';
import 'package:adminui/models/Match.dart';
import 'package:adminui/models/MatchDTO1.dart';
import 'package:adminui/models/User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import '../models/matchsforgrid.dart';
class UsersDBProvider {
  String scheme = 'https';
 int port = 443;
String server = 'landingstennis.com';

 

/*
  String server = 'localhost';

  int port = 52175;

  String scheme = 'http';
*/

 // UsersDBProvider() {

 // }


  Future<UsersResponse>  getUsers() async {
    UsersResponse resp = new UsersResponse();
    var response;
    Iterable list;
    var url = new Uri(scheme: scheme,
      host: server,
      port: port,

      path: '/api/Account/getUsers',
    );
    try {
      response = await http.get(url);
      list = json.decode(response.body);

    } catch (error, stacktrace) {
         print("Exception occured: $error stackTrace: $stacktrace");
         resp.error = error.toString();
         return resp;
    }
    resp.users = list.map((model) => User.fromJson(model)).toList();
    return resp;
  }
Future<MatchsDTOResponse>  getAllMatchs(DateTime date) async {
    MatchsDTOResponse resp = new MatchsDTOResponse();
    var response;
    Iterable list;
try {
    var queryParameters1 = {
      'month': date.month.toString(),
      'year':date.year.toString()
    };
print('month is ' + queryParameters1[0].toString());

    var url = new Uri(scheme: scheme,
      host: server,
      port: port,

      path: '/api/Account/GetAllMatchs',
      queryParameters:queryParameters1

    );
    print('url is ' + url.toString());
      response = await http.get(url);
      list = json.decode(response.body);

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      resp.error = error.toString();
      return resp;
    }
    resp.matches  = list.map((model) => MatchDTO.fromJSON(model)).toList();

    return resp;
  }

  Future<BookedDatesResponse>  getMonthStatus(DateTime picked) async {
    BookedDatesResponse resp = new BookedDatesResponse();
    var response;
    Iterable list;
    var queryParameters1 = {
      'month': picked.month.toString(),
      'year' : picked.year.toString()

    };
    var url = new Uri(scheme: scheme,
      host: server,
      port:port,

      path: '/api/Account/GetMonthStatus',
      queryParameters:queryParameters1
    );
    try {
      response = await http.get(url);
      list = json.decode(response.body);

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      resp.error = error.toString();
      return resp;
    }
    resp.datesandstatus = list.map((model) => PlayersinfoandBookedDates.fromJson(model)).toList();
    return resp;
  }

  Future<UsersResponse>  saveMatches(List<Match> matches) async {
    UsersResponse resp = new UsersResponse();
    String js = jsonEncode(matches);
    var response;
    Iterable list;
    var url = new Uri(scheme: scheme,
      host: server,
      port: port,

      path: '/api/Account/Matches',
    );
    try {
      final response = await http.post(
          url,
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
          body: js
      );

      resp.error = '200';
      if (response.statusCode != 200) {
        resp.error = response.statusCode.toString() + ' ' + response.body;
      }
    } catch (e) {
      resp.error = e.toString();
    }

    return resp;
  }

  Future<bool>  freezedatabase(bool state) async {

    var response;
    String list;
    var queryParameters1 = {
      'state': 'true',

    };
    //all calls to the server are now secure so must pass the oAuth token or our call will be rejected
 //   String authorization = 'Bearer ' + Globals.token;
    Map usermap;
    try {
      var url = new Uri(scheme: scheme,
          host: server,
          port: port,
          path: '/api/Account/freezedatabase',
          queryParameters:queryParameters1
      );


      response = await http.post(url
  //        headers: {HttpHeaders.authorizationHeader: authorization}

      );
  //    String test = json.decode(response.body);

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");

      return false;
    }

    return  true;
    //   return resp;
  }

  Future<bool>  zeroCaptainCount() async {
    var response;
    String list;

    //all calls to the server are now secure so must pass the oAuth token or our call will be rejected
    //   String authorization = 'Bearer ' + Globals.token;
    Map usermap;
    try {
      var url = new Uri(scheme: scheme,
          host: server,
          port: port,
          path: '/api/Account/zeroCaptainCounts',

      );


      response = await http.post(url
        //        headers: {HttpHeaders.authorizationHeader: authorization}

      );
 //     String test = json.decode(response.body);

    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");

      return false;
    }

    return  true;
    //   return resp;
  }
    Future<User>  getUser(String Name) async {
    User user = User();
    
    var response;
    
    var queryParameters1 = {
      'userid': Name,

    };
    
    Map<String,dynamic> usermap;
    try {
      var url = new Uri(scheme: scheme,
          host: server,
          port: port,
          path: '/api/Account/GetUserbyUserID',
          queryParameters:queryParameters1
      );


      response = await http.get(url,
          

      );
      
      usermap = json.decode(response.body);
      user = User.fromJson(usermap);
    } catch (error, stacktrace) {
        print("Exception occured: $error stackTrace: $stacktrace");
       // resp.error = error.toString();

    }
    finally {
      return user;
    }


  }

  Future<UsersResponse> changeuser(User user) async {
    print ('In changeuser for ${user.Userid}');
    UsersResponse resp = UsersResponse();
    String js;
    js = jsonEncode(user);

    //from the emulator 10.0.2.2 is mapped to 127.0.0.1  in windows
    var uri =  Uri(scheme: scheme,
        host: server,
        port: port,
        //      host: targethost,
        path: "api/Account/ChangeUser");

    try {
      // final request = await client.p;
      final response = await http
          .post(uri,
          headers: {"Content-Type": "application/json"},
          body: js)
          .then((response) {
        resp.error = '200';
        if ( response.statusCode != 200) {

          resp.error = response.statusCode.toString() + ' ' + response.body;
        }
      });

    }  catch (e) {
      resp.error = 'update failed';
    }

    return resp;

  }
  

  // ...existing code...

  Future<bool> addClubMember(String username) async {
    var response;
    try {
      var url = Uri(
        scheme: scheme,
        host: server,
        port: port,
        path: '/api/Account/addMember',
        queryParameters: {'username': username},
      );
      response = await http.post(url);
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to add member: ${response.body}');
        return false;
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return false;
    }
  }

//
}


