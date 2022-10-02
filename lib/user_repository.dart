import 'package:dio/dio.dart';
import 'package:single_token_renewal/session_handler.dart';

class UserRepository {
  
  final Dio dio;
  
  UserRepository({required this.dio});

  Future<String> getData(bool isUnauthorized, String message) async {
    try {
      dio.options.headers["Authorization"] = SessionHandler.token;
      var request = await dio.get("/test/unauthorized", queryParameters: {
        "is_unauthorized": isUnauthorized ? 1 : 0,
        "message": message
      });
      return request.toString();
    } on Exception catch (e) {
      return mapError(e);
    }
  }

  Future<String> getHolaData(bool isUnauthorized) async {
    var request = await getData(isUnauthorized, "Holaa...");
    return request.toString();
  }

  Future<String> getVoilaData(bool isUnauthorized) async {
    var request = await getData(isUnauthorized, "Voilaa...");
    return request.toString();
  }

  Future<Response<dynamic>> renewToken() async {
    var request = await dio.get("/test/renew-token");
    return request;
  }

  String mapError(Exception e) {
    if (e is DioError) {
      return e.response.toString();
    } else {
      return "Unknown Error";
    }
  }
}