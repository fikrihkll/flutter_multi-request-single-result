import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:single_token_renewal/refresh_token_handler.dart';
import 'package:single_token_renewal/user_repository.dart';

class UnauthorizedInterceptor extends Interceptor {

  final Dio dio;

  UnauthorizedInterceptor({required this.dio});

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {

      var newToken = await RefreshTokenHandler.getInstance()
          .subscribeRefreshTokenStatus(dio.options.headers["Authorization"],).future;


     if (newToken.isError) {
       super.onError(err, handler);
     } else {
       await _handleOnSuccessRenewal(newToken.newAccessToken, err, handler);
     }
    }
  }

  Future<void> _handleOnSuccessRenewal(String newToken, DioError err, ErrorInterceptorHandler handler) async {
    RequestOptions? options = err.response?.requestOptions;
    if (options != null) {
      var query = options.queryParameters;
      query["is_unauthorized"] = 0;
      dio.options.headers["Authorization"] = newToken;
      var retriedRequest = await dio.request(
          options.path,
          options: Options(method: options.method, sendTimeout: options.sendTimeout, receiveTimeout: options.receiveTimeout,),
          queryParameters: query,
          data: options.data
      );
      handler.resolve(retriedRequest);
    } else {
      super.onError(err, handler);
    }
  }
}