import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:single_token_renewal/session_handler.dart';
import 'package:single_token_renewal/unauthorized_interceptor.dart';
import 'package:single_token_renewal/user_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late UserRepository repository;

  String response = "No response yet";
  String response2 = "No response yet";

  @override
  void initState() {
    super.initState();

    var dio = Dio(BaseOptions(baseUrl: "https://api.fikrihkl.me/api"));
    dio.interceptors.add(UnauthorizedInterceptor(dio: dio));
    repository = UserRepository(dio: dio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(response),
            Container(width: 80, height: 1, color: Colors.black,),
            Text(response2),
            const SizedBox(height: 32,),
            Text("Token: ${SessionHandler.token}"),
            MaterialButton(
                child: const Text("Unauthorize"),
                onPressed: () {
                  _setLoading();

                  _getHolaData(true);
                  _getVoilaData(true);
            }),
            const SizedBox(height: 16,),
            MaterialButton(
                child: const Text("Authorize"),
                onPressed: () {
                  _setLoading();

                  _getHolaData(false);
                  _getVoilaData(false);
                }),
            MaterialButton(
                child: const Text("Renew"),
                onPressed: () {
                  _renewToken();
                })
          ],
        ),
      ),
    );
  }

  void _setLoading() {
    response = "Loading...";
    response2 = "Loading...";
    setState(() {

    });
  }

  void _getHolaData(bool isUnauthorized) async {
    response = await repository.getHolaData(isUnauthorized);
    setState(() {
    });
  }

  void _getVoilaData(bool isUnauthorized) async {
    response2 = await repository.getVoilaData(isUnauthorized);
    setState(() {
    });
  }

  void _renewToken() async {
    var data = await repository.renewToken();

    if (data.statusCode == 200) {
      debugPrint("NEW => ${data.data["data"]["new_token"]}");
      SessionHandler.token = data.data["data"]["new_token"].toString();
      repository.dio.options.headers["Authorization"] = SessionHandler.token;
      setState(() {

      });
    }
  }
}
