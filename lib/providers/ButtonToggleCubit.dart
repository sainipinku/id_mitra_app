import 'package:flutter_bloc/flutter_bloc.dart';

enum ToggleType { all,product, concept }

class ButtonToggleCubit extends Cubit<ToggleType> {
  ButtonToggleCubit() : super(ToggleType.all);

  void selectAll() => emit(ToggleType.all);
  void selectProduct() => emit(ToggleType.product);
  void selectConcept() => emit(ToggleType.concept);
}
