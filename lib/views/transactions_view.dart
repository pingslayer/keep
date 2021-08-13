import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../utility/db.dart';
import '../utility/sync.dart';

class Transactions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TransactionsState();
  }
}

class _TransactionsState extends State<Transactions> with TickerProviderStateMixin {
  String title = 'Keep History';
  bool isTitleSelected = false;
  bool isSyncInProgress = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController _syncIconController;

  @override
  void initState() {
    super.initState();
    isSyncInProgress = false;
    _syncIconController = AnimationController(
      duration: Duration(milliseconds: 5000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _syncIconController.dispose();
    super.dispose();
  }

  Future<List> _buildTransactionTiles() async {
    List transactions = await DatabaseManager.instance.queryAllTransactionsDescOrder();
    return transactions;
  }

  String getFormattedDate(String createdAt) {
    DateTime dateTime = DateTime.parse(createdAt);
    final DateFormat formatter = DateFormat('dd-MMM-yyyy h:m:s');
    final String formatted = formatter.format(dateTime);
    return formatted;
  }

  void _sync() async {
    if(isSyncInProgress) {
      return;
    }
    _syncIconController.repeat();
    SyncManager syncManager = new SyncManager();

    String message = '';
    isSyncInProgress = true;

    //sync all
    int responseCode = await syncManager.syncAll();

    if(responseCode == 0) {
      message = 'Nothing to sync';
    } else if(responseCode == 1) {
      message = 'Sync successful: upload';
    } else if(responseCode == 2) {
      message = 'Sync successful: download';
    } else if(responseCode == 3) {
      message = 'Server error';
    } else if(responseCode == 4) {
      message = 'Server not found';
    } else {
      message = 'Action failed';
    }
    _syncIconController.reset();
    isSyncInProgress = false;
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: RotationTransition(
              child: GestureDetector(
                onTap: _sync,
                child: Icon(
                  Icons.sync,
                  size: 26.0,
                ),
              ),
              turns: Tween(begin: 3.0, end: 0.0).animate(_syncIconController)
            )
          )
        ],
        centerTitle: true,
        title: InkWell(
          onTap: () {
            setState(() {
              isTitleSelected = !isTitleSelected;
              title = isTitleSelected ? 'Pingslayer' : 'Keep History';
            });
          },
          child: AnimatedDefaultTextStyle(
            style: isTitleSelected
                ? TextStyle(color: Colors.lightBlue, fontSize: 18)
                : TextStyle(color: Colors.white, fontSize: 18),
            duration: const Duration(milliseconds: 500),
            child: Text(title),
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.color,
      ),
      body: Padding(
        padding: EdgeInsets.all(5.0),
        child: Card(
          color: Theme.of(context).backgroundColor,
          child: FutureBuilder(
            initialData: [],
            future: _buildTransactionTiles(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {

              if(snapshot.data.length == 0) {
                return Container(
                  child: Center(
                    child: Text('No data found', style: Theme.of(context).textTheme.headline3),
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {

                  int holding = snapshot.data[index]['holding'];
                  int deeds = snapshot.data[index]['deeds'];
                  int direction = snapshot.data[index]['direction'];
                  String createdAt = getFormattedDate(snapshot.data[index]['created_at']);

                  IconData iconDirection;
                  Color iconColor;
                  if(direction == 1) {
                    iconDirection = Icons.arrow_upward;
                    iconColor = Colors.green;
                  } else {
                    iconDirection = Icons.arrow_downward;
                    iconColor = Colors.red;
                  }

                  var title = RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '$holding', style: Theme.of(context).textTheme.headline4),
                        TextSpan(text: '    '),
                        TextSpan(text: '($deeds)', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w100, color: Colors.grey)),
                      ]
                    ),
                  );

                  return ListTile(
                    title: title,
                    subtitle: Text(createdAt, style: Theme.of(context).textTheme.headline5),
                    trailing: CircleAvatar(
                      backgroundColor: iconColor,
                      child: Icon(iconDirection),
                    ),
                  );

                },
              );
            },
          )
        ),
      ),
    );
  }

}