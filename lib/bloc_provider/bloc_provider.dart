
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/providers/login_auth/login_cubit.dart';




class BlocProviders {
  static final List<BlocProvider> providers = [
    BlocProvider<LoginCubit>(create: (context) => LoginCubit()),
  ];
}
