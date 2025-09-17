import 'package:adminui/repository/UserRepository.dart';
import 'package:flutter/material.dart';
import 'editaddusers.dart';

Drawer showMyMenu(context,List<int> indexes ,UserRepository _repository){

  var items = <Widget>[];
  var header = new Container(
    height: 20.0,
    child: DrawerHeader(

        margin: EdgeInsets.all(0.0),
        padding: EdgeInsets.all(0.0), child: null,
    ),
  );
  items.add(header);

  indexes.forEach((i) {
    var tile;
    switch (i) {
      case 1:
        tile = new ListTile(
          title: Text('Zero captain counts'),
              onTap : () async  {
                
                await _repository.zeroCaptainCount();
          },
        );
        break;
      case 2:
        tile = new ListTile(
          title: Text('Freeze DB'),
          onTap: ()  async {
            await _repository.freezedatabase();

          },
        );
        break;

      case 3:
        tile = new ListTile(
          title: Text('Unfreeze DB'),
          onTap: () async {
            await _repository.freezedatabase();

          },
        );
        break;
      case 4:
        tile = new ListTile(
          title: Text('version 1.4'),
          onTap: () async {
            // Version info, no action
          },
        );
        break;
      case 5:
        tile = new ListTile(
          title: Text('Edit User'),
          onTap: () async {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const UserIdPromptPage()),
            );
          },
          
        );
        break;
        case 6:
        tile = new ListTile(
          title: Text('new member'),
          onTap: () async {
            String? memberName = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                TextEditingController controller = TextEditingController();
                return AlertDialog(
                  title: Text('Enter Member Name'),
                  content: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: "Member Name"),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(controller.text.trim());
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
            if (memberName != null && memberName.isNotEmpty) {
              // Handle the new member name here
               await _repository.addClubMember(memberName);
            }
          },
        );
        break;

    }
    items.add(tile);

  });
  return Drawer(child: ListView(children: items));
}