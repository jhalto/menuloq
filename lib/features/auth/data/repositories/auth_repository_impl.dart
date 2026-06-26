import 'package:menuloq/features/auth/data/data_sources/remote/auth_remote_data_source.dart';

import '../../domain/repositories/auth_repository.dart';
import '../models/register_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<void> register({
    required String businessName,
    required String userName,
    required String ownerName,
    required String email,
    required String mobileNumber,
    required String password,
    required String passwordConfirmation,
  }) async {
    final request = RegisterRequestModel(
      businessName: businessName,
      userName: userName,
      ownerName: ownerName,
      email: email,
      mobileNumber: mobileNumber,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    await _remoteDataSource.register(request);
  }
}