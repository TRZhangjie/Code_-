import 'package:meta/meta.dart';

@immutable
class ManagersState {
  final int _count;
  get count => _count;
  ManagersState(this._count);
  ManagersState.initState() : _count = 0;
}

enum Action { increment }

ManagersState reducer(ManagersState state, action) {
  if (action == Action.increment) {
    return ManagersState(state.count + 1);
  }
  return state;
}