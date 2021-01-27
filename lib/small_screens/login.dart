import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starboard/app_models/app_model.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

const OAUTH_STATE_STRING = "oauth_authentication_state_string";

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "LoginScaffold");
  StreamSubscription<Uri> deepLinkStream;
  var prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();

    getInitialUri().then((uri) async {
      if (uri == null) {
        return;
      }

      // For some reason, we might get the same initial URI multiple times
      // This happens on hot restart
      // Just remember the last URI and only do something if it changed.
      const l = "lastAuthenticationDeepLinkGenerated";
      var sp = await prefs;
      if (sp.containsKey(l)) {
        var last = sp.getString(l);
        var lastDeepLinkUri = Uri.parse(last);

        if (uri != lastDeepLinkUri) {
          sp.setString(l, uri.toString());
        } else {
          return;
        }
      } else {
        sp.setString(l, uri.toString());
      }

      _tryLoggingInWithDeepLink(uri);
    });

    deepLinkStream = getUriLinksStream().listen(_tryLoggingInWithDeepLink);

    prefs.then((prefs) {
      if (prefs.containsKey("rememberedCredentials")) {
        String json = prefs.getString("rememberedCredentials");
        context.read<AppModel>().restoreFromSavedCredentials(json);
        Navigator.of(scaffoldKey.currentContext).pushReplacementNamed("/home");
      }
    });
  }

  @override
  void dispose() {
    deepLinkStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: MaterialButton(
          child: Text("Sign in"),
          onPressed: () async {
            String state = Uuid().v4();
            (await prefs).setString(OAUTH_STATE_STRING, state);
            var appState = context.read<AppModel>();
            appState.renewState();
            Uri url = appState.reddit.auth.url(["*"], state);
            launch(url.toString());
          },
        ),
      ),
    );
  }

  void _tryLoggingInWithDeepLink(Uri deepLink) async {
    try {
      String code = await _extractCodeFromDeepLink(deepLink);
      print("Code: $code");
      var reddit = context.read<AppModel>().reddit;
      await reddit.auth.authorize(code);

      // Remember credentials
      (await prefs)
          .setString("rememberedCredentials", reddit.auth.credentials.toJson());

      Navigator.of(scaffoldKey.currentContext).pushReplacementNamed("/home");
    } on String catch (errorMessage) {
      scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } on StateError catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(e.message)));
    } on Exception catch (e) {
      scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<String> _extractCodeFromDeepLink(Uri uri) async {
    String state = uri.queryParameters["state"];
    String savedState = (await prefs).getString(OAUTH_STATE_STRING);
    if (state != savedState) {
      return Future.error("An error has occurred. Try again.");
    }
    if (uri.queryParameters["error"] == "access_denied") {
      return Future.error("Access denied");
    }
    String code = uri.queryParameters["code"];
    if (code == null) {
      return Future.error("An error has occurred. Try again.");
    }
    return code;
  }

  Future<void> saveUserCredentials(String json) async {}
}
