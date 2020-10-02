import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starboard/app_models/home_feed.dart';
import 'package:starboard/small_screens/home_feed.dart';
import 'package:starboard/small_screens/post.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Starboard',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (_) => ChangeNotifierProvider(
              create: (_) {
                return HomeFeedModel()..fetchMorePosts();
              },
              child: HomeFeed(),
            ),
        '/comments': (_) => Post(),
      },
      initialRoute: '/',
    );
  }
}
