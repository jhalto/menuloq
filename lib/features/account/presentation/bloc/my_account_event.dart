import 'package:equatable/equatable.dart';
import 'package:menuloq/features/account/domain/params/update_my_account_params.dart';


sealed class MyAccountEvent extends Equatable {
  const MyAccountEvent();

  @override
  List<Object?> get props => [];
}

class MyAccountStarted extends MyAccountEvent {
  const MyAccountStarted();
}

class MyAccountRefreshRequested extends MyAccountEvent {
  const MyAccountRefreshRequested();
}

class MyAccountSaveRequested extends MyAccountEvent {
  const MyAccountSaveRequested({
    required this.params,
  });

  final UpdateMyAccountParams params;

  @override
  List<Object> get props => [params];
}

class MyAccountMessageDismissed extends MyAccountEvent {
  const MyAccountMessageDismissed();
}
