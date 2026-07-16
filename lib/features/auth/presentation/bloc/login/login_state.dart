import 'package:thermo_humi/features/auth/domain/entities/user_entity.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserEntity user;

  LoginSuccess(this.user);
}

class LoginError extends LoginState {
  final String message;
  final Map<String, String>? fieldErrors;

  LoginError(this.message, {this.fieldErrors});
}
