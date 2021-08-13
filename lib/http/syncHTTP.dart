import 'dart:convert' as convert;
import 'dart:io';
import 'package:http/http.dart' as http;

import '../constants/urls.dart';

class SyncHTTP {

  Future<Map> getSyncDirection(appSyncValue) async {
    var url = mainURL+'sync/direction';
    var data = convert.jsonEncode({'appSyncValue': appSyncValue});
    var response = new Map();
    try {
      var responseHTTP = await http.post(
        url,
        body: data,
        headers: _setHeaders(),
      );
      if(responseHTTP.statusCode == 200) {
        response['status'] = "1";
        response['data'] = convert.jsonDecode(responseHTTP.body);
        return response;
      } else {
        response['status'] = "2";
        response['data'] = convert.jsonDecode(responseHTTP.body);
        return response;
      }
    } on Exception {
      response['status'] = "0";
      return response;
    }
  }

  Future<Map> uploadAll(records, transactions) async {
    var url = mainURL+'sync/save/all';
    var data = convert.jsonEncode({
      'records': records,
      'transactions': transactions
    });
    var response = new Map();
    try {
      var responseHTTP = await http.post(
        url,
        body: data,
        headers: _setHeaders(),
      );
      if(responseHTTP.statusCode == 200) {
        response['status'] = "1";
        response['data'] = convert.jsonDecode(responseHTTP.body);
        return response;
      } else {
        response['status'] = "2";
        response['data'] = convert.jsonDecode(responseHTTP.body);
        return response;
      }
    } on Exception {
      response['status'] = "0";
      return response;
    }
  }

  _setHeaders() => {
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };

}