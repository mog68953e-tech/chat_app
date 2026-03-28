import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/datasources/users_remote_datasource.dart';

part 'users_state.dart';

/// Manages live user list with local search filtering
class UsersCubit extends Cubit<UsersState> {
  final UsersRemoteDatasource _datasource;
  StreamSubscription? _usersSub;
  List<UserEntity> _allUsers = [];

  UsersCubit(this._datasource) : super(UsersInitial());

  void loadUsers(String excludeUid) {
    emit(UsersLoading());
    _usersSub = _datasource.getAllUsersStream(excludeUid).listen(
      (users) {
        _allUsers = users;
        emit(UsersLoaded(users));
      },
      onError: (e) => emit(UsersError(e.toString())),
    );
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      emit(UsersLoaded(_allUsers));
      return;
    }
    final filtered = _allUsers
        .where((u) =>
            u.displayName.toLowerCase().contains(query.toLowerCase()) ||
            u.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
    emit(UsersLoaded(filtered));
  }

  @override
  Future<void> close() {
    _usersSub?.cancel();
    return super.close();
  }
}
