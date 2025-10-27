
import 'package:adminui/models/BookedDatesResponse.dart';
import 'package:adminui/models/playerdata.dart';
import 'package:adminui/showMenu.dart';
import 'models/MatchDTO1.dart';

//import 'package:adminui/models/playerinfo.dart';
import 'package:flutter/material.dart';
import 'package:adminui/repository/UserRepository.dart';
import 'package:adminui/models/UsersResponse.dart';
import 'package:adminui/models/User.dart';
import 'package:adminui/models/Match.dart';
import 'package:adminui/models/PlayersinfoandBookedDate.dart';
import 'package:adminui/models/playerinfo.dart';
import 'package:adminui/Calendar.dart';
import 'dart:convert';

//at end of the year look for hardcoded date

class adminui extends StatefulWidget {
  @override
  _adminuiState createState() => _adminuiState();
}

class _adminuiState extends State<adminui> {
  bool _value = false;
  int index = -1;
 bool bDone = false;
  late UsersResponse response;
  late BookedDatesResponse bookingsresp;

  DateTime selectedDate = DateTime.now();
  late List<PlayersinfoandBookedDates> Doubles;

  List<List<PlayersinfoandBookedDates>> columnData = [];
  List<bool> hasCaptain = new List<bool>.filled(12, false);
  final UserRepository _repository = UserRepository();
  List<Calendar>? _DatesMonth;
   DateTime? pickeddate;
 
  int activeDay = 0;
  List<PlayerData> playersinfo = [];
  List<PlayerData> allPlayers = [];
    Map<String,double> columnswidths = Map();
  List<String> columns = [];
  bool saveBtnswitchState = false;
  bool startBtnswitchState = true;
  bool gridBtnswitchState = true;
  List<Match> allmatchs = [];
  List<DateTime> dates = [];
  //map of string to int
var tracknumbermatches = Map<String, int>();
  List months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec'
  ];
  int yearofmatch = DateTime.now().year;
  DateTime currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (DateTime.now().month == 12) yearofmatch = DateTime.now().year + 1;
   
    for (int i = 0; i < 12; i++) {
      hasCaptain[i] = false;
    }
    //   getMatchs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Landings MWF Scheduler 1.42"),
            backgroundColor: Colors.redAccent,
            actions: <Widget>[
  
           ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: Text("showGridforMonth",
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                  onPressed: showGridforMonth),
              
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: Text("Start",
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                  onPressed: startBtnswitchState ? () => {newMonth()} : null),

                  
                 
              IconButton(
                  icon: Icon(Icons.save),
                  onPressed: saveBtnswitchState ? () => {save()} : null
              ),
               IconButton(
                  icon: Icon(Icons.adobe),
                  onPressed: saveBtnswitchState ? () => {showGridforMonth()} : null),   
            ]),
        drawer: showMyMenu(context, [1, 2, 3, 4, 5,6], _repository),
        body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: BuildColumns())
            //       )
            )
        // )

        );
  }

  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    //do not allow captain to be moved
    List<PlayersinfoandBookedDates> info = columnData[columnData.length - 1];
    PlayersinfoandBookedDates usertomove = info[oldIndex];
    if (usertomove.bIsCaptain) {
      _showDialog('captain cannot be moved', false);
      return;
    }
    
    setState(() {
      
      info.removeAt(oldIndex);
      info.insert(newIndex, usertomove);
    });
  }

  setFreeze() async {
    bDone = true;
    await _repository.freezedatabase();
  }

  

  newMonth() async {
    
    
    //we want the calendar to start on first MWF that does not have matchs and must do this step as
    //the datepicker will throw if start date is not one of the selectableDayPredicate (nuts)
    DateTime start = DateTime.now();
    for (int i = 0; i < 31; i++) {
      if (_decideWhichDayToEnable(start)) break;
      start = start.add(new Duration(days: 1));
    }

    pickeddate = await showDatePicker(
        context: context,
        initialDate: start,
        // Refer step 1
        firstDate: DateTime(2000),
        lastDate: DateTime(2035),
        selectableDayPredicate: _decideWhichDayToEnable);
    //get the bookable days in the month
    _DatesMonth = CustomCalendar().getMonthCalendar1(
        pickeddate!.month, pickeddate!.day, yearofmatch,
        startWeekDay: StartWeekDay.monday);
    //find the first MWF of selected  month

   
    bookingsresp = await _repository.getMonthStatus(pickeddate!);
    startBtnswitchState = false;
    saveBtnswitchState = true;
    addColumn();
  }

  addColumn() async {
    List<PlayersinfoandBookedDates> players =
        getPlayersforDay(bookingsresp.datesandstatus, pickeddate!);
    players.sort((a, b) => a.user!.level!.compareTo(b.user!.level!));
    if (players.length < 4) {
      _showDialog('no players for this day', false);
      _DatesMonth?.removeAt(0);
      pickeddate = _DatesMonth?.first.date;
      addColumn();
    } else
      setState(() {
        dates.add(pickeddate!);
        columnData.add(players);
      });
  }

  List<Widget> BuildColumns() {
    var widg3;
    List<Widget> dayInfo = [];

    int editablecol = columnData.length - 1;
    int col = 0;
    double width = 400;
    //columnData.sort((a, b) => a.user.compareTo(b.first.Month!)
    Iterator iter = columnData.iterator;
    while (iter.moveNext()) {
      //   columnData.forEach((list) {
      List<PlayersinfoandBookedDates> list = iter.current;
      if (col > 30) break;
      //  if (list.first.day == selectedDate.day)
      //       var tt =0;
      String p = months[list.first.Month! - 1] + ' ' + dates[col].day.toString();
      width = 400;
      if (col != editablecol) width = 200;
      widg3 =
          new Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //         Expanded(
        //           child:
        Container(
            width: width,
            height: 70,
            child: Column(children: [
              Center(
                child: Text(p,
                    style: TextStyle(
                      //                  height: 3.0,
                      fontSize: 15.2,
                      fontWeight: FontWeight.bold,
                    )),

                //   Text('March 9', style: TextStyle(height: 3.0, fontSize: 21.2, fontWeight: FontWeight.bold,)),
              ),
              //           Row(children: [
              ListTile(
                  key: ValueKey(0),
                  title: Row(children: <Widget>[
                    col == editablecol
                        ? Flexible(
                            flex: 3, fit: FlexFit.tight, child: Text("  Name"))
                        : Container(),
                    col == editablecol
                        ? Flexible(
                            flex: 1, fit: FlexFit.tight, child: Text("times"))
                        : Container(),
                    col == editablecol
                        ? Flexible(
                            flex: 1, fit: FlexFit.tight, child: Text("level"))
                        : Container(),
                    col == editablecol
                        ? Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Text("captain "))
                        : Container(),
                  ]
                      //         ),
                      //   Text('March 9', style: TextStyle(height: 3.0, fontSize: 21.2, fontWeight: FontWeight.bold,)),
                      )
                  ),
            ]
         )
        ),
        Expanded(
            child: Container(
                width: width,
                height: 1200,
                decoration: BoxDecoration(
                    border: Border(
                        right: BorderSide(
                            width: 6,
                            color: Colors.white,
                            style: BorderStyle.solid))),
                child: col == editablecol
                    ? ReorderableListView(
                        onReorder: onReorder,
                        children: getPlayers(list, col, editablecol),
                      )
                    : ListView(
                        children: getPlayers(list, col, editablecol),
                      )
               )
              )
      ]);
      col++;
      if (col > 7) dayInfo.removeAt(0);
      dayInfo.add(widg3);
    }

    return dayInfo;
  }

  save() async {
 //   if (bDone) return;
  
    List<Match> matches = [];
    List<PlayersinfoandBookedDates> info = columnData[columnData.length - 1];
    int count = 1;
    List<String> players = [];
    String? Captain = "not";
     for (int i = 0; i < info.length; i++) {
    

      if (info[i].bIsCaptain == true) Captain = info[i].user?.Name;
      players.add(info[i].user!.Name!);
      if (count % 4 == 0) {
        if (Captain == "not") {
          _showDialog('all matchs must have a Captain', true);
          return;
        }
        Match m = new Match();
        m.id = 1;
        m.day = pickeddate?.day;
        m.month = pickeddate?.month;
        m.year = pickeddate?.year;
        m.level = 1;
        m.Captain = Captain;

        m.players = players;
        matches.add(m);
        players = [];
        Captain = "not";
      }
      ;

      count++;
    }
//   check for players not matched and set level to 99 for them
    if (players.length > 0) {
      Match m = new Match();
      m.id = 1;
      m.day = pickeddate?.day;
      m.month = pickeddate?.month;
      m.year = pickeddate?.year;
      m.level = 99;
      m.players = players;
      matches.add(m);
    }
    
    for (var match in matches)
    {
      for(var player in match.players!)
              {
                if (tracknumbermatches[player] == null)
                tracknumbermatches[player]  = 1;
                else
                  tracknumbermatches[player]  = tracknumbermatches[player]! + 1  ;
              } 
          
  }
 //   response = await _repository.saveMatches(matches);

    //the first column becomes new day to be editted
    _DatesMonth?.removeAt(0);
    if (_DatesMonth!.isEmpty) {
      _showDialog('that all Folks', false);
     
    
      
                     
      return;
    }
    pickeddate = _DatesMonth?.first.date;
    bookingsresp = await _repository.getMonthStatus(pickeddate!); //CLUDGE
    //no captains assigned by default
    for (int i = 0; i < 12; i++) {
      hasCaptain[i] = false;
    }
    addColumn();
  }
 showGridforMonth() async{
pickeddate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        // Refer step 1
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
        selectableDayPredicate: _decideWhichDayToEnable);
    //get the bookable days in the month
    _DatesMonth = CustomCalendar().getMonthCalendar1(
        pickeddate!.month, pickeddate!.day, yearofmatch,
        startWeekDay: StartWeekDay.monday);
    //find the first MWF of selected  month

   
   // bookingsresp = await _repository.getMonthStatus(pickeddate!);
    

 }

  List<PlayersinfoandBookedDates> getPlayersforDay(
      List<PlayersinfoandBookedDates> datesandstatus, DateTime selectedDate) {
    int count = 1;
    List<PlayersinfoandBookedDates> playersforday = [];
    for (int i = 0; i < datesandstatus.length; i++) {
      List<String>? daystatus = datesandstatus[i].status?.split(',');
      if (daystatus?[selectedDate.day] != '0')
        continue; //only thos avaiable and want to play

      //need new reference
      //   PlayersinfoandBookedDates newInfo = PlayersinfoandBookedDates.fromJson(datesandstatus[i].toJson());;
      //    newInfo.user = User.fromJson(datesandstatus[i].user.toJson());;
      datesandstatus[i].bIsCaptain = false;
      datesandstatus[i].day = selectedDate.day;
      playersforday.add(datesandstatus[i]);
    }
 //   playersforday.sort((a, b) => a.user?.level?.compareTo(b.user.level));
    ;
    return playersforday;
    ;
  }

  bool _decideWhichDayToEnable(DateTime day) {
    List<Match> filter = allmatchs
        .where(
            (element) => element.month == day.month && element.day == day.day)
        .toList();
    if (filter.length > 0) return false;
    if (day.weekday == 1 || day.weekday == 3 || day.weekday == 5) return true;
    return false;
  }

  void _showDialog(String err, bool isError) {
    String message = "";
    if (isError) message = "internal logic error";
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(message),
          content: new Text(err),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> getPlayers(
      List<PlayersinfoandBookedDates> playersforday, int col, editablecol) {
    List<Widget> items = [];

    int count = 1;
    int nTimesplayed = 0;
    var back = Colors.black;
    if (col != editablecol) back = Colors.grey;
    for (int i = 0; i < playersforday.length; i++) {
      double width = 0;
      //can only have one captain per team
      if (count % 4 == 0) width = 16;
      if (tracknumbermatches[playersforday[i].user!.Name!] == null)
         nTimesplayed = 0;
      else
        nTimesplayed = tracknumbermatches[playersforday[i].user!.Name!]!;
      count++;
      var temp = Column(
        key: ValueKey(i),
        //set mainAxisSize to min to avoid items disappearing on reorder
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: back,
                border: Border(
                    bottom: BorderSide(
                        width: width,
                        color: Colors.blueGrey,
                        style: BorderStyle.solid))),
            child: ListTile(
              key: ValueKey(i),
              title: Row(children: <Widget>[
                Flexible(
                    flex: 3,
                    fit: FlexFit.tight,
                    child: Text(playersforday[i].user!.Name!)),
                col == editablecol
                    ? Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Text(
                            playersforday[i].user!.timesCaptain.toString() +
                                ' ' +
                                playersforday[i].user!.notused.toString() + 
                                ' ' + nTimesplayed.toString() 
                            )
                          )
                    : Container(),
                col == editablecol
                    ? Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Text(playersforday[i].user!.level.toString()))
                    : Container(),
                 Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Checkbox(
                            value: playersforday[i].bIsCaptain,
                            onChanged: (value) {
                              setState(() {
                                int teamnumber = (i ~/ 4);
                                bool captainassigned = hasCaptain[teamnumber];

                                if (value == true) {
                                  if (captainassigned) {
                                    _showDialog(
                                        "only one captain per team", true);
                                    return;
                                  }

                                  playersforday[i].user?.timesCaptain += 1;
                                  hasCaptain[teamnumber] = true;
                                } else {
                                  playersforday[i].user?.timesCaptain -= 1;
                                  hasCaptain[teamnumber] = false;
                                }
                                playersforday[i].bIsCaptain =
                                    !playersforday[i].bIsCaptain;
                              });
                            }
                            )
                        )

                ]
              ),
              //    controlAffinity: ListTileControlAffinity.leading,
              autofocus: false,
              //     activeColor: Colors.green,
              //     checkColor: Colors.white,
              selected: index == i,
              //     value: index == i,
              //     onChanged: (bool value) {
              //      setState(() {
              //       index = i;
              //      _value = true;
              //       });
              //      }
            ),
            //        i % 4 == 0 ?Divider(height:100) :Divider(height:0)
          )
        ],
      );
      items.add(temp);
    }

    return items;
  }
  Future <void> getUsersandInitGrid( DateTime date,UserRepository _repository) async {
    try{
    List<MatchDTO> matchs ;
    List<User> allusers = [];
  
  late List<Calendar> _daysinMonth;
  
  
    playersinfo.clear();
    allPlayers.clear();
    columns.clear();
    UsersResponse resp =    await _repository.getUsers();
    allusers = resp.users;
    var resp1 = await _repository.getAllMatchs(date);
    BookedDatesResponse bookingsresp = await _repository.getMonthStatus(date);
    
    matchs = resp1.matches;

    //    _tennisDataGridSource.matchs = matchs;

    
    
    columns.add( 'Name');
    columnswidths['Name'] = 150;
  //  if (bLoggedIn) {
      columns.add('EMail');
      columnswidths['EMail'] = 200;
      columns.add('Phone');
      columnswidths['Phone'] = 150;
  //  }
//use the first bookings for month to get the M-W-F for grid headings
    int day = -1;
    List<String>? statusdays = bookingsresp.datesandstatus[0].status?.split(',');
    _daysinMonth = CustomCalendar().getJustMonthCalendar(date, statusdays!, startWeekDay: StartWeekDay.monday);
    for(int day =0;day < _daysinMonth.length;day++)
    {
      if (_daysinMonth[day].date!.month == date.month) {
        if (_daysinMonth[day].date!.weekday == 1 ||
            _daysinMonth[day].date!.weekday == 3 ||
            _daysinMonth[day].date!.weekday == 5) {
          if (!columns.contains(
              _daysinMonth[day].date!.day.toString())) {
            columns.add(
                _daysinMonth[day].date!.day.toString());
            columnswidths[_daysinMonth[day].date!.day.toString()] = 50;
          }
        }
      }
    }
// loop thru every player who registered for month and their playing status (available,sub, etc) this way we
    //pickup the people who were subs and the ones who were available but were not booked
    bookingsresp.datesandstatus.forEach((booking) {


      PlayerData playerinfo = new PlayerData();
      playerinfo.matches =  List<int>.filled(32, 0, growable: false);
      bool bActivePlayer = false;
      if (booking.user!.phonenum == null)
        booking.user!.phonenum = '1111111111';
      playerinfo.name = booking.user?.Name ?? '';
      playerinfo.email = booking.user?.Email ?? '';
      playerinfo.phonenum = booking.user?.phonenum ?? '';
      allPlayers.add(playerinfo);
      statusdays = booking.status?.split(',') ?? [];
      //create a list of days in month and the players status for that day
      _daysinMonth = CustomCalendar().getJustMonthCalendar(date, statusdays ?? [], startWeekDay: StartWeekDay.monday);
      statusdays = booking.status?.split(',') ?? [];
      int col = 0;

      for(int day =0;day < _daysinMonth.length;day++)
      {

        // if a M-W-F
        if (_daysinMonth[day].date!.weekday == 1 ||
            _daysinMonth[day].date!.weekday == 3 ||
            _daysinMonth[day].date!.weekday == 5) {
          if (_daysinMonth[day].state == 1) {
            bActivePlayer = true;
            playerinfo.matches[col] = 99;    //a sub
          }
          if (_daysinMonth[day].state == 0) {
            findMatch(matchs,allusers,_daysinMonth[day].date!.day,playerinfo,col);
            bActivePlayer = true;
          }

        }

        //  }
        col++;
      }

      if (bActivePlayer)
        playersinfo.add(playerinfo);
    });
    }
    catch (e) {
      print(e);
    }
  }
  findMatch( List<MatchDTO> matchs,List<User> allusers,int day,PlayerData playerinfo,int columnNum){

    List<MatchDTO> matchsforday = matchs.where((element) =>
    element.day == day).toList();
    int iNumMatch = 0;
    bool bFound = false;
    //we are processing member by member . look thru the matchs for this day and see if member is
    //in the match and if they are the captain
    matchsforday.forEach((matchforday) {
      iNumMatch++;
      for (int ii = 0; ii < 4; ii++) {
        User user = allusers.where((u) => u.Email == matchforday.players[ii] ).single;
        if (user.Name== playerinfo.name) {
          bFound = true;
          playerinfo.matches[columnNum] = iNumMatch;
          if (playerinfo.name == matchforday.Captain) {
            playerinfo.CaptainthatDay[columnNum] = 1;
          }

        }
      }
      if (!bFound)  //player was left out as not enough players
        playerinfo.matches[columnNum] = 88;
    });


  }
}
