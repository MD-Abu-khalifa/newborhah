import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/shared_value_helper.dart';

class Otp extends StatefulWidget {
  String? title;
  Otp({Key? key, this.title}) : super(key: key);

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  TextEditingController _verificationCodeController = TextEditingController();

  onTapResend() async {
    var resendCodeResponse = await AuthRepository().getResendCodeResponse();
    ToastComponent.showDialog(resendCodeResponse.message!);
  }

  onPressConfirm() async {
    var code = _verificationCodeController.text;

    if (code.isEmpty) {
      ToastComponent.showDialog("الرجاء إدخال رمز التحقق");
      return;
    }

    try {
      var confirmCodeResponse = await AuthRepository().getConfirmCodeResponse(code);
      if (!confirmCodeResponse.result) {
        ToastComponent.showDialog(confirmCodeResponse.message);
      } else {
        ToastComponent.showDialog(confirmCodeResponse.message);

        // الحصول على بيانات المستخدم
        var loginResponse = await AuthRepository().getUserByTokenResponse();
        if (loginResponse.result == true) {
          AuthHelper().setUserData(loginResponse);
          context.go("/"); // التوجه إلى الشاشة الرئيسية بعد النجاح
        } else {
          ToastComponent.showDialog(loginResponse.message);
        }
      }
    } catch (e) {
      ToastComponent.showDialog("حدث خطأ أثناء التحقق من الكود، حاول مرة أخرى.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screen_width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              color: Colors.red,
              width: _screen_width,
              height: 200,
              child: Image.asset(
                "assets/splash_login_registration_background_image.png",
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.title != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(widget.title!, style: TextStyle(fontSize: 25, color: MyTheme.font_grey)),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0, bottom: 15),
                      child: Container(
                        width: 75,
                        height: 75,
                        child: Image.asset('assets/login_registration_form_logo.png'),
                      ),
                    ),
                    Container(
                      width: _screen_width * 0.75,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildVerificationCodeField(),
                          buildConfirmButton(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: InkWell(
                        onTap: onTapResend,
                        child: Text(
                          "إعادة إرسال الرمز",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: MyTheme.accent_color, decoration: TextDecoration.underline, fontSize: 13),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: InkWell(
                        onTap: () {
                          onTapLogout(context);
                        },
                        child: Text("الغاء التحقق", textAlign: TextAlign.center, style: TextStyle(color: MyTheme.accent_color, decoration: TextDecoration.underline, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVerificationCodeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        height: 45,
        child: TextField(
          controller: _verificationCodeController,
          autofocus: false,
          decoration: InputDecoration(
            hintText: "A X B 4 J H",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }

  Widget buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyTheme.accent_color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          onPressed: onPressConfirm,
          child: Text(
            "تأكيد",
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  onTapLogout(BuildContext context) {
    AuthHelper().clearUserData();
    context.go("/"); // التوجه إلى الشاشة الرئيسية
  }
}
