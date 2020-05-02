import 'package:dadguide2/components/config/settings_manager.dart';
import 'package:dadguide2/components/models/enums.dart';
import 'package:dadguide2/components/utils/build_mode.dart';
import 'package:dadguide2/l10n/localizations.dart';
import 'package:dadguide_admin/components/routes.dart';
import 'package:dadguide_admin/components/service_locator.dart';
import 'package:flutter/material.dart';

void main() async {
  // This works around the fact that we're using an async main, which implies that maybe we should
  // not be using an async main.
  WidgetsFlutterBinding.ensureInitialized();

  // Automatically swap to local endpoints for development
  await initializeServiceLocator(useDevEndpoints: buildMode == BuildMode.debug);

  await Prefs.init();
  Prefs.setAllCountry(Country.na.id);
  Prefs.setAllLanguage(Language.en.id);

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
      localizationsDelegates: [
        DadGuideLocalizationsDelegate(),
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('ja'), // Japanese
        const Locale('ko'), // Korean
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: Routes.router.generator,
    );
  }
}
