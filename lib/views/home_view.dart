import 'package:flutter/material.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';

import '../utility/db.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> with TickerProviderStateMixin {

  int upCount = 0;
  int downCount = 0;
  int holdingsValue = 0;

  Color _confirmationBtnBackgroundColorEnd = Colors.white;

  String getCreatedAt() {
    var now = new DateTime.now();
    return now.toIso8601String();
  }

  void _up() async {
    await DatabaseManager.instance.insertRecord({
      'deed': 1,
      'created_at': getCreatedAt(),
      'status': 1,
    });
    upCount = await DatabaseManager.instance.getRecordsCountByDeedActive(1);
    await DatabaseManager.instance.increaseSyncValue();
    _setButtonBackgroundColorEnd();
    setState(() {});
  }

  void _down() async {
    await DatabaseManager.instance.insertRecord({
      'deed': 0,
      'created_at': getCreatedAt(),
      'status': 1,
    });
    downCount = await DatabaseManager.instance.getRecordsCountByDeedActive(0);
    await DatabaseManager.instance.increaseSyncValue();
    _setButtonBackgroundColorEnd();
    setState(() {});
  }

  void _keep() async {
    if(upCount == 0 && downCount == 0) {
      return;
    }
    int deeds = upCount - downCount;
    await DatabaseManager.instance.updateHoldings(deeds);
    holdingsValue = await DatabaseManager.instance.getHoldingsValue();

    int direction = deeds > 0 ? 1 : 0;
    await DatabaseManager.instance.insertTransaction({
      'holding': holdingsValue,
      'deeds': deeds,
      'direction': direction,
      'created_at': getCreatedAt(),
      'status': 1,
    });

    await DatabaseManager.instance.updateAllRecordsStatus(0);
    await DatabaseManager.instance.increaseSyncValue();
    _initDeeds();
    setState(() {});
  }

  void _initDeeds() async {
    upCount = await DatabaseManager.instance.getRecordsCountByDeedActive(1);
    downCount = await DatabaseManager.instance.getRecordsCountByDeedActive(0);
    holdingsValue = await DatabaseManager.instance.getHoldingsValue();
    _setButtonBackgroundColorEnd();
    setState(() {});
  }

  void _setButtonBackgroundColorEnd() {
    _confirmationBtnBackgroundColorEnd = upCount > downCount ? Colors.green[300] : Colors.red[300];
  }

  @override
  void initState() {
    super.initState();
    _initDeeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 50.0),
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/transactions');
          },
          child: Center(
            child: Text(
              '$holdingsValue',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 100.0),
        ),
        Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: GestureDetector(
                    onTap: _up,
                    child: Image.asset(
                      'assets/images/arrow_up.png',
                      height: 100,
                      width: 200,
                    ),
                  )),
              Expanded(
                  child: GestureDetector(
                    onTap: _down,
                    child: Image.asset(
                      'assets/images/arrow_down.png',
                      height: 100,
                      width: 200,
                    ),
                  ))
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 50.0),
        ),
        Center(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: Center(
                      child: Text(
                        '$upCount',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    )),
                Expanded(
                    child: Center(
                      child: Text(
                        '$downCount',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    )),
              ]),
        ),
        Container(
          margin: const EdgeInsets.only(top: 50.0),
        ),
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 50, bottom: 100),
            child: ConfirmationSlider(
              text: "Keep?",
              textStyle: Theme.of(context).textTheme.button,
              backgroundColorEnd: _confirmationBtnBackgroundColorEnd,
              onConfirmation: () {
                _keep();
              },
            ),
          ),
        ),
      ]),
    );
  }
}
