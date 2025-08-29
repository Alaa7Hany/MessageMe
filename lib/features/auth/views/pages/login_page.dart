import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/extensions/navigation_extensions.dart';
import 'package:message_me/core/widgets/my_snackbar.dart';
import 'package:message_me/core/helpers/text_field_validator.dart';
import 'package:message_me/core/widgets/loading_screen_overlay.dart';

import 'package:message_me/features/auth/logic/auth_cubit/auth_cubit.dart';
import 'package:message_me/core/widgets/my_elevated_button.dart';
import 'package:message_me/features/auth/views/widgets/logo_widget.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/my_textform_field.dart';
import '../../logic/auth_cubit/auth_state.dart';
import '../widgets/auth_footer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool isVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isVisible = false;
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = AuthCubit.get(context);
    return Stack(
      children: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              MySnackbar.error(context, state.message);
            } else if (state is AuthLoginSuccess) {
              MySnackbar.success(context, state.message);
              context.pushReplacementNamed(Routes.home);
            }
          },
          child: _buildUI(authCubit),
        ),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return state is AuthLoading ? LoadingScreenOverlay() : SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildUI(AuthCubit authCubit) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30.h),
                  const LogoWidget(),
                  SizedBox(height: 30.h),
                  _loginForm(),
                  SizedBox(height: 30.h),
                  MyElevatedButton(
                    label: 'Login',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        authCubit.loginWithEmailAndPassword(
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                    },
                  ),
                  SizedBox(height: 50.h),
                  const AuthFooter(inLogin: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          MyTextformField(
            label: 'Email',
            controller: _emailController,
            validator: TextFieldValidator.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 20.h),
          MyTextformField(
            label: 'Password',
            controller: _passwordController,
            validator: TextFieldValidator.validatePassword,
            isObsecure: !isVisible,
            keyboardType: TextInputType.visiblePassword,

            suffixIcon: InkWell(
              child: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
              onTap: () {
                setState(() {
                  isVisible = !isVisible;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
