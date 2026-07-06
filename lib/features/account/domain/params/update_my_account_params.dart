import 'package:equatable/equatable.dart';

class UpdateMyAccountParams extends Equatable {
  const UpdateMyAccountParams({
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.address,
  });

  final String name;
  final String email;
  final String mobileNumber;
  final String address;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile_number': mobileNumber,
      'address': address,
    };
  }

  @override
  List<Object> get props => [
        name,
        email,
        mobileNumber,
        address,
      ];
}
