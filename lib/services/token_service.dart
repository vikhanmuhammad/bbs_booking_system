import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bbs_booking_system/common/failure.dart';
import 'package:bbs_booking_system/model/token_model.dart';
import 'package:http/http.dart' as http;

class TokenService {
  Future<Either<Failure, TokenModel>> getToken(
      {required String productName,
      required double totalPayment,
      required String id}) async {
    var apiUrl = dotenv.env['API_PY'] ?? '';

    // Payload
    var payload = {
      "orderId": id, // Unique Id
      "productName": productName,
      "totalPayment": totalPayment,
    };

    var payloadJson = jsonEncode(payload);

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: payloadJson,
      );

      print(apiUrl);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return right(TokenModel(token: jsonResponse['token']));
      } else {
        return left(ServerFailure(
            data: response.body,
            code: response.statusCode,
            message: 'Jam tersebut sudah terisi'));
      }
    } catch (e) {
      return left(ServerFailure(
          data: e.toString(), code: 400, message: 'Unknown Error'));
    }
  }
}
