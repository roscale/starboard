import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starboard/app_state.dart';
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
      try {
        String code = await _validateDeepLink(uri);
        print("Code: $code");
        await context.read<AppState>().reddit.auth.authorize(code);
      } on String catch (errorMessage) {
        scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    });

    deepLinkStream = getUriLinksStream().listen((uri) async {
      try {
        String code = await _validateDeepLink(uri);
        print("Code: $code");
        await context.read<AppState>().reddit.auth.authorize(code);
      } on String catch (errorMessage) {
        scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text(errorMessage)));
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
            var appState = context.read<AppState>();
            appState.renewState();
            Uri url = appState.reddit.auth.url(["*"], state);
            launch(url.toString());
          },
        ),
      ),
    );
  }

  Future<String> _validateDeepLink(Uri uri) async {
    String state = uri.queryParameters["state"];
    String savedState = (await prefs).getString(OAUTH_STATE_STRING);
    if (state != savedState) {
      return Future.error("An error has occured. Try again.");
    }
    if (uri.queryParameters["error"] == "access_denied") {
      return Future.error("Access denied");
    }
    String code = uri.queryParameters["code"];
    if (code == null) {
      return Future.error("An error has occured. Try again.");
    }
    return code;
  }
}
