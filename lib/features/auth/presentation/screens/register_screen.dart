import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/my_primary_button.dart';
import '../../data/data_sources/remote/auth_api.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/register_usecase.dart';
import '../cubits/register_cubit.dart';
import '../cubits/register_state.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController emailController;
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;

    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => RegisterCubit(
        registerUseCase: RegisterUsecase(AuthRepositoryImpl(AuthApi(client))),
      ),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .center,
                      children: [
                        //icon
                        const SizedBox(height: 72),
                        const Icon(
                          Icons.lock,
                          color: AppColors.onSurface,
                          size: 72,
                        ),
                        //welcome text
                        const SizedBox(height: 24),
                        Text(
                          "Welcome to MapMemo!",
                          style: theme.textTheme.headlineMedium,
                        ),

                        // email
                        const SizedBox(height: 48),
                        AuthTextField(
                          hintText: "Enter your email",
                          controller: emailController,
                          obscureText: false,
                        ),

                        // username
                        const SizedBox(height: 24),
                        AuthTextField(
                          hintText: "Enter your username",
                          controller: usernameController,
                          obscureText: false,
                        ),

                        // password
                        const SizedBox(height: 24),
                        AuthTextField(
                          hintText: "Enter your password",
                          controller: passwordController,
                          obscureText: true,
                        ),

                        // confirm password
                        const SizedBox(height: 24),
                        AuthTextField(
                          hintText: "Confirm your password",
                          controller: confirmPasswordController,
                          obscureText: true,
                        ),

                        // auth button
                        const SizedBox(height: 24),
                        MyPrimaryButton(
                          onPressed: () {
                            context.read<RegisterCubit>().register(
                              emailController.text,
                              usernameController.text,
                              passwordController.text,
                              confirmPasswordController.text,
                              context,
                            );
                          },
                          label: "Sign Up",
                        ),

                        // login navigate
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: .center,
                          spacing: 4,
                          children: [
                            const Text("Have an account?"),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.login,
                                );
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
