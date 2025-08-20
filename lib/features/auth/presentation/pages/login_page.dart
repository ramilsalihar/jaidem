import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/widgets/app_button.dart';
import 'package:jaidem/core/widgets/app_text_form_field.dart';
import 'package:jaidem/features/auth/presentation/cubit/auth_cubit.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.2),
            Image.asset(
              'assets/images/app_icon.png',
              width: 100,
            ),
            const SizedBox(height: 30),
            Text(
              'Вход на Жайдемчи',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 30),
            AppTextFormField(
              labelText: 'Телефон или Email',
              keyboardType: TextInputType.emailAddress,
              controller: loginController,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Пароль',
              obscureText: true,
              controller: passwordController,
            ),
            const SizedBox(height: 30),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return AppButton(
                  text: 'Войти',
                  isLoading: state is AuthLoading,
                  onPressed: () {
                    final username = loginController.text.trim();
                    final password = passwordController.text.trim();
                    
                    if (username.isNotEmpty && password.isNotEmpty) {
                      context.read<AuthCubit>().login(username, password);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
