import 'dart:io';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/google_recaptcha.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/auth/login.dart';
import 'package:active_ecommerce_flutter/screens/common_webview_screen.dart';
import 'package:active_ecommerce_flutter/ui_elements/auth_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
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
  String _register_by = "email"; //phone or email
  String initialCountry = 'US';

  var countries_code = <String?>[];

  String? _phone = "";
  bool? _isAgree = false;
  bool _isCaptchaShowing = false;
  String googleRecaptchaKey = "";

  //controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

  @override
  void initState() {

    // تفعيل تسجيل الدخول عبر جوجل عند بدء التطبيق
    allow_google_login.$ = true;  // تعديل القيمة
    allow_google_login.save();    // حفظ التغيير في shared_preferences
    allow_apple_login.$ = true;  // تعديل القيمة
    allow_apple_login.save();
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    fetch_country();
  }

  fetch_country() async {
    var data = await AddressRepository().getCountryList();
    data.countries.forEach((c) => countries_code.add(c.code));
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressSignUp() async {
    Loading.show(context);

    var name = _nameController.text.toString();
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();
    var password_confirm = _passwordConfirmController.text.toString();

    if (name == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_your_name,
      );
      return;
    } else if (_register_by == 'email' && (email == "" || !isEmail(email))) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_email,
      );
      return;
    } else if (_register_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_phone_number,
      );
      return;
    } else if (password == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_password,
      );
      return;
    } else if (password_confirm == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.confirm_your_password,
      );
      return;
    } else if (password.length < 6) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!
            .password_must_contain_at_least_6_characters,
      );
      return;
    } else if (password != password_confirm) {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.passwords_do_not_match,
      );
      return;
    }

    var signupResponse = await AuthRepository().getSignupResponse(
        name,
        _register_by == 'email' ? email : _phone,
        password,
        password_confirm,
        _register_by,
        googleRecaptchaKey);
    Loading.close();

    if (signupResponse.result == false) {
      var message = "";
      signupResponse.message.forEach((value) {
        message += value + "\n";
      });

      ToastComponent.showDialog(
        message,
      );
    } else {
      ToastComponent.showDialog(
        signupResponse.message,
      );
      AuthHelper().setUserData(signupResponse);

      // redirect to main
      // Navigator.pushAndRemoveUntil(context,
      //     MaterialPageRoute(builder: (context) {
      //       return Main();
      //     }), (newRoute) => false);
      // context.go("/");

      // push notification starts
      if (OtherConfig.USE_PUSH_NOTIFICATION) {
        final FirebaseMessaging _fcm = FirebaseMessaging.instance;
        await _fcm.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        String? fcmToken = await _fcm.getToken();

        if (fcmToken != null) {
          print("--fcm token--");
          print(fcmToken);
          if (is_logged_in.$ == true) {
            // update device token
            var deviceTokenUpdateResponse = await ProfileRepository()
                .getDeviceTokenUpdateResponse(fcmToken);
          }
        }
      }

      // context.go("/");

      if ((mail_verification_status.$ && _register_by == "email") ||
          _register_by == "phone") {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Otp(
            // verify_by: _register_by,
            // user_id: signupResponse.user_id,
          );
        }));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Login();
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
        context,
        "${AppLocalizations.of(context)!.join_ucf} " + AppConfig.app_name,
        buildBody(context, _screen_width));
  }

  Column buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _screen_width * (3 / 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // حقل إدخال الاسم
                    Text(
                      AppLocalizations.of(context)!.name_ucf,
                      style: TextStyle(
                        color: MyTheme.accent_color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 48,
                      child: TextField(
                        controller: _nameController,
                        autofocus: false,
                        decoration: InputDecorations.buildInputDecoration_1(
                          hint_text: "Borhah Borhah",
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // التحقق مما إذا كان التسجيل بالبريد الإلكتروني أو الهاتف
                    Text(
                      _register_by == "email"
                          ? AppLocalizations.of(context)!.email_ucf
                          : AppLocalizations.of(context)!.phone_ucf,
                      style: TextStyle(
                        color: MyTheme.accent_color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),

                    // حقل إدخال البريد الإلكتروني أو الهاتف بناءً على الاختيار
                    if (_register_by == "email")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 48,
                            child: TextField(
                              controller: _emailController,
                              autofocus: false,
                              decoration: InputDecorations.buildInputDecoration_1(
                                hint_text: "borhah@gmail.com",
                              ),
                            ),
                          ),
                          otp_addon_installed.$
                              ? Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _register_by = "phone";
                                });
                              },
                              child: Text(
                                AppLocalizations.of(context)!.or_register_with_a_phone,
                                style: TextStyle(
                                  color: MyTheme.accent_color,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          )
                              : Container(),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // حقل إدخال رقم الهاتف
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: MyTheme.accent_color, width: 1),
                            ),
                            height: 50,
                            child: CustomInternationalPhoneNumberInput(
                              countries: countries_code,
                              onInputChanged: (PhoneNumber number) {
                                setState(() {
                                  _phone = number.phoneNumber;
                                });
                              },
                              onInputValidated: (bool value) {
                                print(value);
                              },
                              selectorConfig: SelectorConfig(
                                selectorType: PhoneInputSelectorType.DIALOG,
                              ),
                              ignoreBlank: false,
                              autoValidateMode: AutovalidateMode.disabled,
                              selectorTextStyle: TextStyle(color: MyTheme.font_grey),
                              textFieldController: _phoneNumberController,
                              formatInput: true,
                              keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                              inputDecoration: InputDecorations.buildInputDecoration_phone(hint_text: "XXX XXX XXX"),
                            ),
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _register_by = "email";
                                });
                              },
                              child: Text(
                                AppLocalizations.of(context)!.or_register_with_an_email,
                                style: TextStyle(
                                  color: MyTheme.accent_color,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  AppLocalizations.of(context)!.password_ucf,
                  style: TextStyle(color: MyTheme.accent_color, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // حقل إدخال كلمة المرور
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: MyTheme.textfield_grey),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecorations.buildInputDecoration_1(hint_text: "• • • • • • • •"),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      AppLocalizations.of(context)!.password_must_contain_at_least_6_characters,
                      style: TextStyle(color: MyTheme.textfield_grey, fontStyle: FontStyle.italic, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  AppLocalizations.of(context)!.retype_password_ucf,
                  style: TextStyle(color: MyTheme.accent_color, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: MyTheme.textfield_grey),
                  ),
                  child: TextField(
                    controller: _passwordConfirmController,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecorations.buildInputDecoration_1(hint_text: "• • • • • • • •"),
                  ),
                ),
              ),
// إعادة توجيه السياسات
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // مربع الموافقة على الشروط
                    Checkbox(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      value: _isAgree,
                      onChanged: (newValue) {
                        setState(() {
                          _isAgree = newValue;
                        });
                      },
                    ),
                    SizedBox(width: 8),
                    // نص الشروط وسياسة الخصوصية
                    Expanded(
                      child: RichText(
                        maxLines: 2,
                        text: TextSpan(
                          style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
                          children: [
                            TextSpan(text: "أوافق على "),
                            TextSpan(
                              text: "الشروط والأحكام",
                              style: TextStyle(color: MyTheme.accent_color),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommonWebviewScreen(
                                        page_name: "الشروط والأحكام",
                                        url: "${AppConfig.RAW_BASE_URL}/mobile-page/terms",
                                      ),
                                    ),
                                  );
                                },
                            ),
                            TextSpan(text: " و"),
                            TextSpan(
                              text: "سياسة الخصوصية",
                              style: TextStyle(color: MyTheme.accent_color),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommonWebviewScreen(
                                        page_name: "سياسة الخصوصية",
                                        url: "${AppConfig.RAW_BASE_URL}/mobile-page/privacy-policy",
                                      ),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
// زر التسجيل

              Container(
                height: 50,
                width: double.infinity,
                child: Btn.minWidthFixHeight(
                  minWidth: MediaQuery.of(context).size.width,
                  height: 50,
                  color: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.sign_up_ucf,
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  onPressed: (_isAgree ?? false) ? onPressSignUp : null,

                ),
              ),
              SizedBox(height: 20),
// التوجيه لتسجيل الدخول
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.already_have_an_account,
                    style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    child: Text(
                      AppLocalizations.of(context)!.log_in,
                      style: TextStyle(color: MyTheme.accent_color, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                    },
                  ),
                ],
              ),

            ],
          ),
        )
      ],
    );
  }
}
