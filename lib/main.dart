import 'package:dadguide2/components/settings_manager.dart';
import 'package:dadguide_admin/components/routes.dart';
import 'package:dadguide_admin/components/service_locator.dart';
import 'package:flutter/material.dart';

void main() async {
  // This works around the fact that we're using an async main, which implies that maybe we should
  // not be using an async main.
  WidgetsFlutterBinding.ensureInitialized();

  await initializeServiceLocator(useDevEndpoints: true);

  await Prefs.init();

  Routes.configureRoutes();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DadGuide Admin Tools',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: Routes.router.generator,
    );
  }
}
