import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:starboard/app_models/app_model.dart';

class SubredditSearchBar extends StatefulWidget {
  @override
  _SubredditSearchBarState createState() => _SubredditSearchBarState();
}

class _SubredditSearchBarState extends State<SubredditSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: TypeAheadField(
        hideOnEmpty: true,
        hideOnLoading: true,
        hideOnError: true,
        textFieldConfiguration: TextFieldConfiguration(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            filled: true,
            prefixIcon: Icon(Icons.search),
            hintText: "Search",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        suggestionsBoxDecoration:
            SuggestionsBoxDecoration(color: Colors.grey.shade900),
        suggestionsCallback: (pattern) {
          var reddit = context.read<AppModel>().reddit;
          return reddit.subreddits.searchByName(pattern);
        },
        itemBuilder: (context, SubredditRef subreddit) {
          return ListTile(
            leading: Icon(Icons.public, color: Colors.blue),
            title: Text("r/${subreddit.displayName}"),
          );
        },
        onSuggestionSelected: (suggestion) {
          print(suggestion);
        },
      ),
    );
  }
}
