
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:single_token_renewal/session_handler.dart';
import 'package:single_token_renewal/user_repository.dart';

class RefreshTokenHandler {

  static RefreshTokenHandler? _instance;

  static RefreshTokenHandler getInstance() {
    _instance ??= RefreshTokenHandler();
    return _instance!;
  }

  String _newAccessToken = "";
  String _newRefreshToken = "";

  Completer<RefreshTokenEntity> tokenRenewalCompleter = Completer();
  bool _isAlreadyCalled = false;

  Completer<RefreshTokenEntity> subscribeRefreshTokenStatus(String previousToken) {
    if (_newAccessToken == previousToken || _newAccessToken.isEmpty) {
      debugPrint("DATA => ${_newAccessToken} || ${previousToken}");
      if (!_isAlreadyCalled) {
        _isAlreadyCalled = true;
        tokenRenewalCompleter = Completer();
        _requestRenewToken();
      }
    }
    return tokenRenewalCompleter;
  }

  void _requestRenewToken() async {
    var dio = Dio(BaseOptions(baseUrl: "https://api.fikrihkl.me/api"));
    
    var repository = UserRepository(dio: dio);
    var data = await repository.renewToken();
    if (data.statusCode == 200) {
      _newAccessToken = data.data["data"]["new_token"].toString();
      _newRefreshToken = data.data["data"]["new_token"].toString();
      debugPrint("NEW => ${_newAccessToken} ");
      await _handleSuccessRenew(_newAccessToken);

      tokenRenewalCompleter.complete(
          RefreshTokenEntity(
              isError: false,
              newAccessToken: _newAccessToken,
              newRefreshToken: _newRefreshToken
          )
      );
    } else {
      tokenRenewalCompleter.complete(
          RefreshTokenEntity(
              isError: false,
              newAccessToken: "",
              newRefreshToken: ""
          )
      );
    }
    _isAlreadyCalled = false;
  }

  Future _handleSuccessRenew(String newToken) async {
    SessionHandler.token = newToken;
  }

  String get getAccessToken => _newAccessToken;
  String get getRefreshToken => _newRefreshToken;

}

class RefreshTokenEntity {
  final bool isError;
  final String newAccessToken;
  final String newRefreshToken;

  RefreshTokenEntity({required this.isError, required this.newAccessToken, required this.newRefreshToken});

}