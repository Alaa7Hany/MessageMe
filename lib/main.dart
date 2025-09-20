import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';

import 'core/services/dependency_injection_service.dart';

import 'core/routing/app_router.dart';

import 'firebase_options.dart';
import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Check if the current build number is in the disabled list.
  final bool isThisBuildDisabled = await _isThisBuildDisabled();
  // ------------------------------------

  await setupGetIt();
  runApp(MyApp(appRouter: AppRouter(), isAppEnabled: !isThisBuildDisabled));
}

Future<bool> _isThisBuildDisabled() async {
  // --- Version and Remote Config Logic ---
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      // Set to zero to fetch every time for immediate testing.
      // For a real app, you might set this to Duration(hours: 1).
      minimumFetchInterval: Duration.zero,
    ),
  );
  // Set a default value (an empty JSON) in case the fetch fails.
  await remoteConfig.setDefaults(const {"disabled_versions": "{}"});
  // Fetch the latest values from the Firebase server.
  await remoteConfig.fetchAndActivate();

  // Get the app's package information to find the build number.
  final packageInfo = await PackageInfo.fromPlatform();
  final buildNumber = packageInfo.buildNumber;

  // Get the disabled versions list from Remote Config.
  final disabledVersionsString = remoteConfig.getString('disabled_versions');
  final disabledVersions =
      jsonDecode(disabledVersionsString) as Map<String, dynamic>;
  return disabledVersions[buildNumber] == true;
}
