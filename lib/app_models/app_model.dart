import 'package:draw/draw.dart';
import 'package:shared_preferences/shared_preferences.dart';

// https://github.com/reddit-archive/reddit/wiki/API
const clientId = "ekbE-y3ipmiaZw"; // from https://www.reddit.com/prefs/apps
const userAgent = "android:ro.roscale.starboard:v0.1 (by /u/roscaalex19)";
var redirectUri = Uri.parse("starboard://oauth");

class AppModel {
  Reddit reddit;

  AppModel() {
    renewState();
  }

  void renewState() {
    reddit = Reddit.createInstalledFlowInstance(
      clientId: clientId,
      userAgent: userAgent,
      redirectUri: redirectUri,
    );
  }

  void restoreFromSavedCredentials(String json) {
    reddit = Reddit.restoreInstalledAuthenticatedInstance(
      json,
      clientId: clientId,
      userAgent: userAgent,
      redirectUri: redirectUri,
    );
  }

  Future<void> deleteSavedCredentials() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove("rememberedCredentials");
  }
}
