import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:message_me/core/helpers/text_field_validator.dart';
import 'package:message_me/core/utils/app_assets.dart';
import 'package:message_me/core/utils/app_text_styles.dart';
import 'package:message_me/features/auth/views/widgets/auth_button.dart';
import 'package:message_me/features/auth/views/widgets/logo_widget.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/my_textform_field.dart';
import '../widgets/auth_footer.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
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

                  LogoWidget(),
                  SizedBox(height: 30.h),
                  _loginForm(),
                  SizedBox(height: 30.h),
                  AuthButton(label: 'Login', onPressed: () {}),
                  SizedBox(height: 50.h),
                  AuthFooter(inLogin: true),
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
      child: Column(
        children: [
          MyTextformField(
            label: 'Email',
            controller: TextEditingController(),
            validator: TextFieldValidator.validateEmail,
          ),
          SizedBox(height: 20.h),
          MyTextformField(
            label: 'Password',
            controller: TextEditingController(),
            validator: TextFieldValidator.validatePassword,
            isObsecure: true,
            suffixIcon: Icon(Icons.remove_red_eye_sharp),
          ),
        ],
      ),
    );
  }
}
