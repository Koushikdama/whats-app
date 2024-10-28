import 'package:chatting_app/Common/Screen/Error.dart';
import 'package:chatting_app/Common/widgets/loader.dart';
import 'package:chatting_app/Route.dart';
import 'package:chatting_app/User_info/Controller/userController.dart';
import 'package:chatting_app/auth/login_screen.dart';
import 'package:chatting_app/colors.dart';
import 'package:chatting_app/firebase_options.dart';
import 'package:chatting_app/screens/mobile_layout_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData.dark(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.

          useMaterial3: true,
        ).copyWith(
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: const AppBarTheme(
            color: appBarColor,
          ),
        ),
        onGenerateRoute: (settings) => generateRoute(settings),
        home: ref.watch(userDataAuthprovider).when(
            data: (user) {
              print("user ${user}");
              if (user == null) {
                return const LoginScreen();
              } else {
                return const MobileLayoutScreen();
              }
            },
            error: (err, trace) {
              print("error ${err.toString()}");
              return ErrorScreen(
                error: err.toString(),
              );
            },
            loading: () => const Loader()));
  }
}
