import 'package:equatable/equatable.dart';

enum ChangePasswordStatus { initial, loading, success, failure }

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.status = ChangePasswordStatus.initial,
    this.message,
  });

  final ChangePasswordStatus status;
  final String? message;

  ChangePasswordState copyWith({
    ChangePasswordStatus? status,
    String? message,
    bool clearMessage = false,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
