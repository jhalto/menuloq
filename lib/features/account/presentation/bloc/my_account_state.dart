import 'package:equatable/equatable.dart';
import 'package:menuloq/features/account/domain/entities/my_account_entitry.dart';

enum MyAccountStatus {
  initial,
  loading,
  success,
  failure,
  saving,
}

class MyAccountState extends Equatable {
  const MyAccountState({
    this.status = MyAccountStatus.initial,
    this.account,
    this.errorMessage,
    this.successMessage,
    this.fieldErrors = const {},
  });

  final MyAccountStatus status;
  final MyAccountEntity? account;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, String> fieldErrors;

  bool get isLoading => status == MyAccountStatus.loading;
  bool get isSaving => status == MyAccountStatus.saving;
  bool get hasAccount => account != null;

  MyAccountState copyWith({
    MyAccountStatus? status,
    MyAccountEntity? account,
    String? errorMessage,
    String? successMessage,
    Map<String, String>? fieldErrors,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    bool clearFieldErrors = false,
  }) {
    return MyAccountState(
      status: status ?? this.status,
      account: account ?? this.account,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
      fieldErrors: clearFieldErrors
          ? const {}
          : fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
        status,
        account,
        errorMessage,
        successMessage,
        fieldErrors,
      ];
}
