import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/extensions/navigation_extensions.dart';
import 'package:message_me/core/widgets/my_snackbar.dart';
import 'package:message_me/core/helpers/text_field_validator.dart';
import 'package:message_me/core/widgets/loading_screen_overlay.dart';

import 'package:message_me/features/auth/logic/auth_cubit/auth_cubit.dart';
import 'package:message_me/core/widgets/my_elevated_button.dart';
import 'package:message_me/core/widgets/rounded_image.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/my_textform_field.dart';
import '../../logic/auth_cubit/auth_state.dart';
import '../widgets/auth_footer.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  late PlatformFile? _imageFile;

  bool isVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isVisible = false;
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _imageFile = null;
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
                  InkWell(
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      final imageFile = await authCubit.pickImage();
                      if (imageFile != null) {
                        setState(() {
                          _imageFile = imageFile;
                        });
                      }
                    },
                    child: RoundedImageFile(image: _imageFile, radius: 100),
                  ),
                  SizedBox(height: 30.h),
                  _signupForm(),
                  SizedBox(height: 30.h),
                  MyElevatedButton(
                    label: 'Signup',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        authCubit.registerUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                          name: _nameController.text,
                          imageFile: _imageFile,
                        );
                      }
                    },
                  ),
                  SizedBox(height: 50.h),
                  const AuthFooter(inLogin: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signupForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          MyTextformField(
            label: 'Name',
            controller: _nameController,
            validator: TextFieldValidator.validateName,
          ),
          SizedBox(height: 20.h),
          MyTextformField(
            label: 'Email',
            controller: _emailController,
            validator: TextFieldValidator.validateEmail,
          ),
          SizedBox(height: 20.h),
          MyTextformField(
            label: 'Password',
            controller: _passwordController,
            validator: TextFieldValidator.validatePassword,
            isObsecure: !isVisible,

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
