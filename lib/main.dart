
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:idmitra/Widgets/AppSize.dart';
import 'package:idmitra/bloc_provider/bloc_provider.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/screens/splash/splash.dart';
import 'package:idmitra/utils/GlobalContext.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}
// what are you doing
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppSize.init(context);
    return MultiBlocProvider(
      providers: BlocProviders.providers,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),  // FIXED DESIGN SIZE
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: GlobalContext.navigatorKey,
            builder: (context, child) {
              return SafeArea(
                top: true,
                bottom: true,
                child: child ?? const SizedBox(),
              );
            },
            theme: ThemeData(
              useMaterial3: false,
              scaffoldBackgroundColor: AppTheme.appBackgroundColor, // ✅ Global background
              dividerTheme: const DividerThemeData(
                thickness: 1,
                space: 1,
              ),
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.white,              // ✅ yahan change
                  statusBarIconBrightness: Brightness.dark,  // ✅ Android black icons
                  statusBarBrightness: Brightness.light,     // ✅ iOS black text
                ),
                backgroundColor: AppTheme.appBackgroundColor,
                elevation: 0,
              ),
            ),
            home: Splash(),
          );
        },
      ),
    );
  }
}


