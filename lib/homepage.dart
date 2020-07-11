import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

Future<List<News>> fetchNews(http.Client client) async {
  final url =
      "http://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=31c21508fad64116acd229c10ac11e84";
  // await -> do not execute the function below till time we do not get the data from http client request
  final response = await client.get(url);

  // Here, compute function will execute parseNews function in the background as an ISOLATE
  return compute(
      parseNews, response.body); //response.body -> will be our JSON Data
}

//String parseNews(String responseBody){
List<News> parseNews(String responseBody) {
  // Here jsonData represents Map Data Structure in Dart
  Map<String, dynamic> jsonData = jsonDecode(responseBody);
  // Fetch all the articles as List of JSONs from the jsonData
  List newsList = jsonData['articles'];

  return newsList.map<News>((json) => News.fromJson(json)).toList();
}

// OOPS
class News {
  String title;
  String author;
  String urlToImage;
  String publishedAt;
  String description;
  String url;

  News(
      {this.title,
      this.author,
      this.urlToImage,
      this.publishedAt,
      this.description,
      this.url});

  // In Dart, factory named constructor is the one which will use other constructor to create and return back an object
  factory News.fromJson(Map<String, dynamic> json) {
    // returning back a news object constructed from json
    return News(
      title: json['title'],
      author: json['author'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
      description: json['description'],
      url: json['url'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "News App", home: HomePage(), debugShowCheckedModeBanner: false);
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("News App"),
      ),
      //body: FutureBuilder<String>(
      body: FutureBuilder<List<News>>(
        future: fetchNews(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print("Some Error ${snapshot.error}");
          //return snapshot.hasData ? Center(child: Text(snapshot.data)) : Center(child: CircularProgressIndicator());
          return snapshot.hasData
              ? NewsList(news: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class NewsList extends StatelessWidget {
  final List<News> news;

  NewsList({Key key, this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: news.length,
      itemBuilder: (context, index) {
        // index will begin from 0 till news.length
        return GestureDetector(
          child: Card(
            margin: EdgeInsets.all(10),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(news[index].urlToImage),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    news[index].title + "\n",
                    style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w300),
                  ),
                  Text(
                    "Published By : " + news[index].author,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Updated At : " + news[index].publishedAt,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
                // startActivity()
                context,
                MaterialPageRoute(
                    // Intent
                    builder: (context) => NewsPage(url: news[index].url)));
          },
        );
      },
    );
  }
}

class NewsPage extends StatelessWidget {
  final String url;

  NewsPage({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("News Page"),
        ),
        //body: FutureBuilder<String>(
        body: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
