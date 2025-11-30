import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/data_sources/remote/auth_api.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../cubits/login_cubit.dart';
import '../cubits/login_state.dart';
import '../../../../core/widgets/my_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/square_tile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => LoginCubit(
        loginUseCase: LoginUseCase(AuthRepositoryImpl(AuthApi(client))),
      ),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            debugPrint("Login failed!: ${state.message}");
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is LoginSuccess) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 72),

                        const Icon(
                          Icons.lock,
                          color: AppColors.onSurface,
                          size: 72,
                        ),

                        const SizedBox(height: 24),
                        Text(
                          "Welcome to MapMemo!",
                          style: theme.textTheme.headlineMedium,
                        ),

                        const SizedBox(height: 48),
                        AuthTextField(
                          hintText: "Enter your email",
                          controller: emailController,
                          obscureText: false,
                        ),

                        const SizedBox(height: 24),
                        AuthTextField(
                          hintText: "Enter your password",
                          controller: passwordController,
                          obscureText: true,
                        ),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Forgot your password?",
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: AppColors.onSurfaceGray2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        MyPrimaryButton(
                          onPressed: state is LoginLoading
                              ? null
                              : () {
                                  emailController.text = "viet@gmail.com";
                                  passwordController.text = "viettk12";
                                  context.read<LoginCubit>().login(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                },
                          label: state is LoginLoading
                              ? "Signing in..."
                              : "Sign In",
                        ),

                        const SizedBox(height: 48),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: AppColors.onSurfaceGray2,
                                thickness: 1,
                              ),
                            ),
                            Text(
                              " Or continue with ",
                              style: theme.textTheme.bodyMedium,
                            ),
                            const Expanded(
                              child: Divider(
                                color: AppColors.onSurfaceGray2,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Row(
                          spacing: 16,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SquareTile(imagePath: AppIcons.facebook),
                            SquareTile(imagePath: AppIcons.google),
                          ],
                        ),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 4,
                          children: [
                            const Text("Not a member?"),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.register,
                                );
                              },
                              child: const Text(
                                "Register now",
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
