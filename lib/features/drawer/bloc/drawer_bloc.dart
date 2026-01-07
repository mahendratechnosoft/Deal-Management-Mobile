import 'package:flutter_bloc/flutter_bloc.dart';

part 'drawer_event.dart';
part 'drawer_state.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  DrawerBloc() : super(const DrawerState(selectedIndex: 0)) {
    on<DrawerItemSelected>(
      (event, emit) => emit(DrawerState(selectedIndex: event.index)),
    );
  }
}
