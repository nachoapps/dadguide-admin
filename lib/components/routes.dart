import 'package:dadguide_admin/screens/monster_screen.dart';
import 'package:dadguide_admin/screens/root_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class Routes {
  static final router = Router();

  static String root = '/';
  static String monster = '/monster';

  static void configureRoutes() {
    router.notFoundHandler =
        Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return Text('route not found');
    });
    router.define(root, handler: homeHandler);
    router.define(monster, handler: monsterHandler);
  }
}

var homeHandler = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return HomePage();
});

var monsterHandler = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  var param = int.parse(params['id'][0]);
  return MonsterPage(param);
});
