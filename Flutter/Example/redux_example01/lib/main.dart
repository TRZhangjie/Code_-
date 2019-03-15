import 'package:flutter/material.dart';

/// redux
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'root_page.dart';
import 'package:redux_example01/state/state_managers.dart';

void main(){
  final store =
  Store<ManagersState>(reducer, initialState: ManagersState.initState());
  runApp(new MyApp(store));
}

class MyApp extends StatelessWidget {

  final Store<ManagersState> store;

  MyApp(store);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider<ManagersState>(
      store: store,
      child: MaterialApp(
        title: 'redux_example01',
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        home: RootPage(),
      ),
    );
  }
}
