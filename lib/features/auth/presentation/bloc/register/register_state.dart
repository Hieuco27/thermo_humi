import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterError extends RegisterState {
  final String message;
  final Map<String, String>? fieldErrors;

  const RegisterError(this.message, {this.fieldErrors});

  @override
  List<Object?> get props => [message, fieldErrors];
}
