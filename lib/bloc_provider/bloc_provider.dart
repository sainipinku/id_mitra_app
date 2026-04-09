
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/providers/home/home_cubit.dart';
import 'package:idmitra/providers/login_auth/login_cubit.dart';
import 'package:idmitra/providers/manage_profile/manage_profile_cubit.dart';
import 'package:idmitra/providers/school/school_cubit.dart';
import 'package:idmitra/providers/students/students_cubit.dart';




class BlocProviders {
  static final List<BlocProvider> providers = [
    BlocProvider<LoginCubit>(create: (context) => LoginCubit()),
    BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
    BlocProvider<SchoolCubit>(create: (context) => SchoolCubit()),
    BlocProvider<ManageProfileCubit>(create: (context) => ManageProfileCubit()),
    BlocProvider<StudentsCubit>(create: (context) => StudentsCubit()),
  ];
}
