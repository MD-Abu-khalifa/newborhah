import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/other_config.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:active_ecommerce_flutter/screens/auth/password_forget.dart';
import 'package:active_ecommerce_flutter/screens/auth/registration.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/social_config.dart';
import 'package:active_ecommerce_flutter/ui_elements/auth_ui.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/twitter_login.dart';

import '../../custom/loading.dart';
import '../../repositories/address_repository.dart';
import 'otp.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _login_by = "email"; //phone or email
  String initialCountry = 'US';

  // PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  var countries_code = <String?>[];

  String? _phone = "";

  //controllers
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
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

  onPressedLogin(ctx) async {
    FocusScope.of(context).unfocus();

    Loading.show(context);
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();

    if (_login_by == 'email' && email == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_email,
      );
      return;
    } else if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_phone_number,
      );
      return;
    } else if (password == "") {
      ToastComponent.showDialog(
        AppLocalizations.of(context)!.enter_password,
      );
      return;
    }

    var loginResponse = await AuthRepository().getLoginResponse(
        _login_by == 'email' ? email : _phone, password, _login_by);
    Loading.close();

    // empty temp user id after logged in
    temp_user_id.$ = "";
    temp_user_id.save();

    if (loginResponse.result == false) {
      if (loginResponse.message.runtimeType == List) {
        ToastComponent.showDialog(
          loginResponse.message!.join("\n"),
        );
        return;
      }
      ToastComponent.showDialog(
        loginResponse.message!.toString(),
      );
    } else {
      print("in the success block ");

      ToastComponent.showDialog(
        loginResponse.message!,
      );

      AuthHelper().setUserData(loginResponse);

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

        String? fcmToken;
        try {
          fcmToken = await _fcm.getToken();
        } catch (e) {
          print('Caught exception: $e');
        }

        print("--fcm token--");
        // print("token: $fcmToken");
        // update device token
        if (fcmToken != null && is_logged_in.$) {
          var deviceTokenUpdateResponse =
              await ProfileRepository().getDeviceTokenUpdateResponse(fcmToken);
        }
      }

      // redirect
      if (loginResponse.user!.emailVerified!) {
        context.push("/");
      } else {
        if ((mail_verification_status.$ && _login_by == "email") ||
            (mail_verification_status.$ && _login_by == "phone")) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Otp(
                // verify_by: _register_by,
                // user_id: signupResponse.user_id,
                );
          }));
        } else {
          context.push("/");
        }
      }
    }
  }

  onPressedFacebookLogin() async {
    try {
      final facebookLogin = await FacebookAuth.instance
          .login(loginBehavior: LoginBehavior.webOnly);

      if (facebookLogin.status == LoginStatus.success) {
        // get the user data
        // by default we get the userId, email,name and picture
        final userData = await FacebookAuth.instance.getUserData();
        var loginResponse = await AuthRepository().getSocialLoginResponse(
            "facebook",
            userData['name'].toString(),
            userData['email'].toString(),
            userData['id'].toString(),
            access_token: facebookLogin.accessToken!.tokenString);
        // print("..........................${loginResponse.toString()}");
        if (loginResponse.result == false) {
          ToastComponent.showDialog(
            loginResponse.message!,
          );
        } else {
          ToastComponent.showDialog(
            loginResponse.message!,
          );

          AuthHelper().setUserData(loginResponse);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Main();
          }));
          FacebookAuth.instance.logOut();
        }
        // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      } else {
        print("....Facebook auth Failed.........");
        // print(facebookLogin.status);
        // print(facebookLogin.message);
      }
    } on Exception catch (e) {
      print(e);
      // TODO
    }
  }

  onPressedGoogleLogin() async {
    try {
      final GoogleSignInAccount googleUser = (await GoogleSignIn().signIn())!;

      print(googleUser.toString());

      GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser.authentication;
      String? accessToken = googleSignInAuthentication.accessToken;

      // print("displayName ${googleUser.displayName}");
      // print("email ${googleUser.email}");
      // print("googleUser.id ${googleUser.id}");

      var loginResponse = await AuthRepository().getSocialLoginResponse(
          "google", googleUser.displayName, googleUser.email, googleUser.id,
          access_token: accessToken);

      if (loginResponse.result == false) {
        ToastComponent.showDialog(
          loginResponse.message!,
        );
      } else {
        ToastComponent.showDialog(
          loginResponse.message!,
        );
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
      }
      GoogleSignIn().disconnect();
    } on Exception catch (e) {
      print("error is ....... $e");
      // TODO
    }
  }

  onPressedTwitterLogin() async {
    try {
      final twitterLogin = new TwitterLogin(
          apiKey: SocialConfig().twitter_consumer_key,
          apiSecretKey: SocialConfig().twitter_consumer_secret,
          redirectURI: 'activeecommerceflutterapp://');
      // Trigger the sign-in flow

      final authResult = await twitterLogin.login();

      // print("authResult");

      // print(json.encode(authResult));

      var loginResponse = await AuthRepository().getSocialLoginResponse(
          "twitter",
          authResult.user!.name,
          authResult.user!.email,
          authResult.user!.id.toString(),
          access_token: authResult.authToken,
          secret_token: authResult.authTokenSecret);

      if (loginResponse.result == false) {
        ToastComponent.showDialog(
          loginResponse.message!,
        );
      } else {
        ToastComponent.showDialog(
          loginResponse.message!,
        );
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
      }
    } on Exception catch (e) {
      print("error is ....... $e");
      // TODO
    }
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      var loginResponse = await AuthRepository().getSocialLoginResponse(
          "apple",
          appleCredential.givenName,
          appleCredential.email,
          appleCredential.userIdentifier,
          access_token: appleCredential.identityToken);

      if (loginResponse.result == false) {
        ToastComponent.showDialog(
          loginResponse.message!,
        );
      } else {
        ToastComponent.showDialog(
          loginResponse.message!,
        );
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
      }
    } on Exception catch (e) {
      print(e);
      // TODO
    }

    // Create an `OAuthCredential` from the credential returned by Apple.
    // final oauthCredential = OAuthProvider("apple.com").credential(
    //   idToken: appleCredential.identityToken,
    //   rawNonce: rawNonce,
    // );
    //print(oauthCredential.accessToken);

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    //return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  @override
  Widget build(BuildContext context) {
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return AuthScreen.buildScreen(
        context,
        "${AppLocalizations.of(context)!.login_to} " + AppConfig.app_name,
        buildBody(context, _screen_width));
  }
  Widget buildBody(BuildContext context, double _screen_width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
                  "البريد الإلكتروني",
                  style: TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  "كلمة المرور",
                  style: TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextField(
                  controller: _passwordController,
                  autofocus: false,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: "••••••••",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return PasswordForget();
                    }));
                  },
                  child: Text(
                    "نسيت كلمة المرور؟",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onPressedLogin(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // لون الزر
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "تسجيل الدخول",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: Text(
                  "أو قم بإنشاء حساب جديد",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return Registration();
                    }));
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blueAccent, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "إنشاء حساب جديد",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
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
