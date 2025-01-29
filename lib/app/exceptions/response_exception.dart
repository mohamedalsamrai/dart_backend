import 'dart:convert';

import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';

class ResponseException {
  static Response mysqlException(MySqlException e) {
    return Response.internalServerError(
          body: jsonEncode({
            'error': 'MySQL Error',
            'message': e.message,
            'code': e.errorNumber,
          }),
          headers: {'Content-Type': 'application/json'});
  }
  static Response exception(Object exception){
return Response.internalServerError(
          body: jsonEncode({
            'error': 'خطأ غير متوقع',
            'message': exception.toString(),
          }),
          headers: {'Content-Type': 'application/json'});
  }
}