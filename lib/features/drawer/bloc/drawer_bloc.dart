import 'package:flutter/material.dart';
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

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final String route;
  final bool visible;

  const DrawerMenuItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.visible,
  });
}
