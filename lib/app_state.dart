import 'package:draw/draw.dart';

class AppState {
  Reddit reddit;

  AppState() {
    renewState();
  }

  void renewState() {
    reddit = Reddit.createInstalledFlowInstance(
      // from https://www.reddit.com/prefs/apps
      clientId: "ekbE-y3ipmiaZw",
      userAgent: "android:ro.roscale.starboard:v0.1 (by /u/roscaalex19)",
      redirectUri: Uri.parse("starboard://oauth"),
    );
  }
}
