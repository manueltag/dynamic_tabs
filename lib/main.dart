import 'package:bloc/bloc.dart';
import 'package:dynamic_tabs/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:dynamic_tabs/bloc/bloc.dart';
import 'package:flutter/material.dart';

void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final PostBloc _postBloc = PostBloc(httpClient: http.Client());
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _postBloc.dispatch(Fetch());
    _controller = TabController(vsync: this, length: 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _postBloc,
      builder: (BuildContext context, PostState state) {
        if (state is PostUninitialized) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is PostError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Center(
              child: Text('failed to fetch posts'),
            ),
          );
        }
        if (state is PostLoaded) {
          if (state.posts.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
              ),
              body: Center(
                child: Text('no posts'),
              ),
            );
          }

          // TODO: is this correct?
          _controller = TabController(vsync: this, length: state.posts.length);

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),  
              bottom: TabBar(
                controller: _controller,
                tabs: state.posts
                    .map<Widget>(
                        (Post post) => Tab(text: post.title.toUpperCase()))
                    .toList(),
              ),
            ),
            body: TabBarView(
              children: state.posts.map<Widget>(buildTabView).toList(),
              controller: _controller,
            ),
          );
        }
      },
    );
  }

  Widget buildTabView(Post post) {
    return Container(
      child: Card(
        child: Center(
          child: Text(
            post.body,
            style: TextStyle(
              fontSize: 32.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postBloc.dispose();
    _controller.dispose();
    super.dispose();
  }
}
