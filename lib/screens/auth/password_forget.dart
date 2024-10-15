import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/screens/auth/password_otp.dart';
import 'package:active_ecommerce_flutter/ui_elements/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../repositories/address_repository.dart';

class PasswordForget extends StatefulWidget {
  @override
  _PasswordForgetState createState() => _PasswordForgetState();
}

class _PasswordForgetState extends State<PasswordForget> {
  String _send_code_by = "email"; //phone or email
  String initialCountry = 'US';
  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US');
  String? _phone = "";
  var countries_code = <String?>[];
  //controllers
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetch_country();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressSendCode() async {
    var email = _emailController.text.toString();

    if (_send_code_by == 'email' && email == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_email,
      );
      return;
    } else if (_send_code_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_phone_number,
      );
      return;
    }

    var passwordForgetResponse = await AuthRepository()
        .getPasswordForgetResponse(
            _send_code_by == 'email' ? email : _phone, _send_code_by);

    if (passwordForgetResponse.result == false) {
      ToastComponent.showDialog(
        passwordForgetResponse.message!,
      );
    } else {
      ToastComponent.showDialog(
        passwordForgetResponse.message!,
      );

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PasswordOtp(
          verify_by: _send_code_by,
        );
      }));
    }
  }

  fetch_country() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countries_code.add(c.code));
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
      context,
      "نسيت كلمة المرور!",
      buildBody(_screen_width, context),
    );
  }

  Column buildBody(double _screen_width, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          width: _screen_width * 0.8, // تعديل العرض إلى 80%
          padding: EdgeInsets.all(16.0), // إضافة بعض المسافات حول المحتوى
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1), // إضافة حدود
            borderRadius: BorderRadius.circular(12.0), // زوايا مستديرة
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  _send_code_by == "email"
                      ? "البريد الإلكتروني"
                      : "رقم الهاتف",
                  style: TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ),
              if (_send_code_by == "email")
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 36,
                        child: TextField(
                          controller: _emailController,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: "مثال: borhah@gmail.com",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: Colors.grey, width: 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 36,
                        child: TextField(
                          controller: _phoneNumberController,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: "01710 333 558",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: Colors.grey, width: 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      onPressSendCode();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // لون الزر
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      "إرسال الكود",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


}
