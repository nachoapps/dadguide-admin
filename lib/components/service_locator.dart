import 'dart:io' show HttpHeaders;

import 'package:dadguide_admin/components/api.dart';
import 'package:dadguide_admin/components/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';

/// Global service locator singleton.
final getIt = GetIt.instance;

/// Initialize global singleton dependencies and register with getIt.
Future<void> initializeServiceLocator(
    {bool useDevEndpoints: false, bool logHttpRequests: false}) async {
  getIt.registerSingleton<BaseCacheManager>(DefaultCacheManager());
  var dio = Dio();
  if (logHttpRequests) {
    dio.interceptors.add(LogInterceptor());
  }
  getIt.registerSingleton(dio);

  var endpoints = useDevEndpoints ? DevEndpoints() : ProdEndpoints();
  getIt.registerSingleton<Endpoints>(endpoints);

  getIt.registerSingleton<Api>(Api(dio, endpoints));

  dio.options.headers = {
    HttpHeaders.userAgentHeader: 'DadGuide web',
  };
}
