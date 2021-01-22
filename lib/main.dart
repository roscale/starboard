import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starboard/app_state.dart';
import 'package:starboard/small_screens/login.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => AppState(),
      builder: (context, _) => MaterialApp(
        title: 'Starboard',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/': (_) => LoginScreen(),
          // '/': (_) => ChangeNotifierProvider(
          //       create: (_) {
          //         return HomeFeedModel()..fetchMorePosts();
          //       },
          //       child: HomeFeed(),
          //     ),
          // '/comments': (_) => Post(),
        },
        initialRoute: '/',
      ),
    );
  }
}
