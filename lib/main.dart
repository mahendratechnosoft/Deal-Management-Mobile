import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';
import 'package:xpertbiz/core/constants/app_string.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/features/app_routes.dart';
import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';
import 'package:xpertbiz/features/drawer/bloc/drawer_bloc.dart';
import 'package:xpertbiz/features/task_module/create_task/bloc/create_task_bloc.dart';
import 'package:xpertbiz/features/task_module/task/bloc/task_bloc.dart';
import 'package:xpertbiz/features/task_module/task_deatils/bloc/bloc.dart';
import 'di/injection_container.dart' as di;
import 'features/auth/bloc/auth_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/auth/data/locale_data/module_access.dart';

void main() async {
  di.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ModuleAccessAdapter());
  Hive.registerAdapter(LoginResponseAdapter());
  await Hive.openBox<LoginResponse>(ApiConstants.boxName);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (cntx) => di.sl<AuthBloc>()),
        BlocProvider(create: (cntx) => di.sl<TaskBloc>()),
        BlocProvider(create: (context) => DrawerBloc()),
        BlocProvider(create: (context) => di.sl<CreateTaskBloc>()),
         BlocProvider(create: (context) => di.sl<CommentBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        theme: ThemeData(
          fontFamily: ApiConstants.poppinsFont,
        ),
        routerConfig: AppRouter.router,
        builder: (context, child) {
          Responsive.init(context);
          return child!;
        },
      ),
    );
  }
}
