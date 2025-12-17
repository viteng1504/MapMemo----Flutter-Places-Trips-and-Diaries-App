import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/register_usecase.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUsecase registerUseCase;

  RegisterCubit({required this.registerUseCase}) : super(RegisterInitial());

  Future<void> register(
    String email,
    String username,
    String password,
    String confirmPassword,
    BuildContext context,
  ) async {
    emit(RegisterLoading());
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match. Please try again."),
        ),
      );

      return;
    }
    try {
      await registerUseCase(email, username, password);
      emit(RegisterSuccess());
      if (state is RegisterSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Register successfull!!!")),
        );
      }
    } catch (e) {
      emit(RegisterFailure(e.toString()));
      if (state is RegisterFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Register Fail!!!")));
      }
    }
  }
}
