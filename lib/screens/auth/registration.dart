import 'dart:io';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/google_recaptcha.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/screens/auth/login.dart';
import 'package:active_ecommerce_flutter/ui_elements/auth_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:validators/validators.dart';
import '../../custom/loading.dart';
import '../../helpers/auth_helper.dart';
import '../../repositories/address_repository.dart';
import 'otp.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  String _register_by = "email";
  bool _isAgree = false; // تم تغيير نوع المتغير إلى bool
  bool _isCaptchaShowing = false;
  String googleRecaptchaKey = "";

  // المتحكمات
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

  // دالة الضغط على زر التسجيل
  onPressSignUp() async {
    Loading.show(context);

    var name = _nameController.text.toString();
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();
    var password_confirm = _passwordConfirmController.text.toString();

    if (name.isEmpty) {
      ToastComponent.showDialog("الرجاء إدخال اسمك");
      Loading.close();
      return;
    } else if (email.isEmpty || !isEmail(email)) {
      ToastComponent.showDialog("البريد الإلكتروني غير صالح");
      Loading.close();
      return;
    } else if (password.isEmpty) {
      ToastComponent.showDialog("الرجاء إدخال كلمة المرور");
      Loading.close();
      return;
    } else if (password_confirm.isEmpty) {
      ToastComponent.showDialog("الرجاء تأكيد كلمة المرور");
      Loading.close();
      return;
    } else if (password.length < 6) {
      ToastComponent.showDialog("كلمة المرور يجب أن تحتوي على 6 أحرف على الأقل");
      Loading.close();
      return;
    } else if (password != password_confirm) {
      ToastComponent.showDialog("كلمتا المرور غير متطابقتين");
      Loading.close();
      return;
    }

    try {
      var signupResponse = await AuthRepository().getSignupResponse(
          name, email, password, password_confirm, _register_by, googleRecaptchaKey);
      Loading.close();

      if (signupResponse.result == false) {
        var message = signupResponse.message.join("\n");
        ToastComponent.showDialog(message);
      } else {
        // في حالة نجاح التسجيل، التوجه إلى صفحة OTP للتحقق
        ToastComponent.showDialog('تم انشاء حسابك بنجاح');
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Otp(
            title: "تحقق من بريدك الإلكتروني",
          );
        }));
      }
    } catch (e) {
      Loading.close();
      ToastComponent.showDialog("حدث خطأ أثناء التسجيل، حاول مرة أخرى.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
      context,
      "انضم إلى ${AppConfig.app_name}",
      buildBody(context, _screen_width),
    );
  }

  Column buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _screen_width * 0.8,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم المستخدم
              buildTextInputField("الاسم", "أحمد محمد", _nameController),
              // البريد الإلكتروني
              buildTextInputField("البريد الإلكتروني", "ahmed@example.com", _emailController),
              // كلمة المرور
              buildPasswordInputField("كلمة المرور", "••••••••", _passwordController),
              // تأكيد كلمة المرور
              buildPasswordInputField("تأكيد كلمة المرور", "••••••••", _passwordConfirmController),
              // Checkbox للموافقة على الشروط
              buildCheckboxSection(),
              // زر التسجيل
              buildSignUpButton(),
              // تسجيل الدخول
              buildLoginRow(context),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget buildTextInputField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 45,
            child: TextField(
              controller: controller,
              autofocus: false,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPasswordInputField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 45,
            child: TextField(
              controller: controller,
              autofocus: false,
              obscureText: true,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCheckboxSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 15,
            width: 15,
            child: Checkbox(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              value: _isAgree,
              onChanged: (newValue) {
                setState(() {
                  _isAgree = newValue!;
                });
              },
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey, fontSize: 12),
                children: [
                  TextSpan(text: "أوافق على "),
                  TextSpan(
                    text: "الشروط والأحكام",
                    style: TextStyle(color: Colors.blueAccent),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  TextSpan(text: " و "),
                  TextSpan(
                    text: "سياسة الخصوصية",
                    style: TextStyle(color: Colors.blueAccent),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSignUpButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          onPressed: _isAgree ? onPressSignUp : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Text(
            "تسجيل",
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget buildLoginRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("لديك حساب؟", style: TextStyle(color: Colors.grey, fontSize: 12)),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
            },
            child: Text(
              "تسجيل الدخول",
              style: TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
