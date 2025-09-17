import 'package:adminui/models/User.dart';
import 'package:adminui/models/matchsforgrid.dart';
import 'package:adminui/repository/User_mockprovider.dart';
import 'package:adminui/models/UsersResponse.dart';
import 'package:adminui/models/BookedDatesResponse.dart';
import 'UsersDataBaseProvider.dart';
import 'package:adminui/models/Match.dart';


class UserRepository{
 // UsersMockProvider _apiProvider = UsersMockProvider();
  UsersDBProvider _apiProvider = UsersDBProvider();
  Future<UsersResponse> getUsers() async{
    return _apiProvider.getUsers();
  }
  Future<User> getUser(String Name) async{
    return _apiProvider.getUser(Name);
  }
  
  Future<UsersResponse>  saveMatches  (List<Match> matches)  async {
    return _apiProvider.saveMatches(matches);
  }
  Future<BookedDatesResponse> getMonthStatus(DateTime picked) async{
    return _apiProvider.getMonthStatus( picked);
  }
Future<MatchsDTOResponse>  getAllMatchs(DateTime date) async {
  return _apiProvider.getAllMatchs(date);
}

  Future<bool> freezedatabase() async{
    bool y = true;
    return _apiProvider.freezedatabase(y );
  }
  Future<bool> zeroCaptainCount() async{

    return _apiProvider.zeroCaptainCount();
  }
  Future<Future<UsersResponse>> changeuser(User user) async{

    return _apiProvider.changeuser(user);
  }
  Future<bool> addClubMember(String memberName) async {
    
    return _apiProvider.addClubMember(memberName);
  }

  

}