part of 'drawer_bloc.dart';

abstract class DrawerEvent {}

class DrawerItemSelected extends DrawerEvent {
  final int index;
  DrawerItemSelected(this.index);
}
