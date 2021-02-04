import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starboard/app_models/app_model.dart';
import 'package:starboard/app_models/home_feed.dart';
import 'package:starboard/app_models/posts.dart';
import 'package:starboard/small_screens/home_feed.dart';
import 'package:starboard/small_screens/login.dart';
import 'package:starboard/small_screens/post.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AppModel()),
        Provider(create: (_) => PostsLocalState()),
      ],
      builder: (context, _) => MaterialApp(
        title: 'Starboard',
        theme: ThemeData(
          brightness: Brightness.dark,
          canvasColor: Color(0xFF181818),
          primarySwatch: Colors.blue,
          accentColor: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/': (_) => LoginScreen(),
          '/home': (_) => ChangeNotifierProvider(
                create: (_) {
                  return HomeFeedModel()
                    ..fetchMorePosts(context.read<AppModel>().reddit);
                },
                child: HomeFeed(),
              ),
          '/comments': (_) => Post(),
        },
        initialRoute: '/',
      ),
    );
  }
}
