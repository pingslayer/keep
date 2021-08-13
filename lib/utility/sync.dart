import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../utility/db.dart';
import '../http/syncHTTP.dart';

class SyncManager {

  SyncHTTP syncHTTP;

  SyncManager() {
    syncHTTP = new SyncHTTP();
  }

  /// responseCodes
  /// 0 - nothing to sync
  /// 1 - upload successful
  /// 2 - download successful
  /// 3 - Server error
  /// 4 - Server not found
  Future<int> syncAll() async {
    int responseCode = 0;
    Map syncDirectionResponse = await getSyncDirection();
    if(syncDirectionResponse['status'] == '1') {
      //http response success
      var syncDirection = syncDirectionResponse['data']['syncDirection'];
      if(syncDirection == '1') {
        //upload to server
        responseCode = await uploadAll();
      } else if(syncDirection == '2') {
        //download from server
        await DatabaseManager.instance.updateSyncValue(syncDirectionResponse['data']['serverSyncValue']);
        responseCode = 2;
      } else {
        //nothing to sync
        responseCode = 0;
      }
    } else if(syncDirectionResponse['status'] == '2') {
      //Server error
      responseCode = 3;
    } else {
      //Server not found
      responseCode =  4;
    }
    return responseCode;
  }

  Future<Map> getSyncDirection() async {
    int appSyncValue = await DatabaseManager.instance.getSyncValue();
    Map response = await syncHTTP.getSyncDirection(appSyncValue);
    return response;
  }

  Future<int> uploadAll() async {
    int responseCode = 0;
    List records = await DatabaseManager.instance.queryAllRecords();
    List transactions = await DatabaseManager.instance.queryAllTransactions();
    Map response = await syncHTTP.uploadAll(records, transactions);
    if(response['status'] == '1') {
      //upload to server
      responseCode = 1;
    } else if(response['status'] == '2') {
      //Server error
      responseCode = 3;
    } else {
      //Server not found
      responseCode = 4;
    }
    return responseCode;
  }

}