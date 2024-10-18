var this_year = DateTime.now().year.toString();

class AppConfig {
  static String copyright_text =
      "@برهه" + this_year; //this shows in the splash screen
  static String app_name = "برهه"; //this shows in the splash screen
//e61f6ccc-bf4f-4df0-bfc7-uf8b2632b513db
  static String purchase_code = "25f4cc05-d286-8bc2-9cb7-f8410bbf1740";

  static String system_key ="yasser"; //enter your purchase code for the app from codecanyon

  //Default language config
  static String default_language = "ar";
  static String mobile_app_code = "ar";
  static bool app_language_rtl = true;

  //configure this

  static const bool HTTPS = true;

  static const DOMAIN_PATH = "borhah.com"; //localhost

  //do not configure these below
  static const String API_ENDPATH = "api/v2";
  static const String PROTOCOL = HTTPS ? "https://" : "http://";
  static const String RAW_BASE_URL = "${PROTOCOL}${DOMAIN_PATH}";
  static const String BASE_URL = "${RAW_BASE_URL}/${API_ENDPATH}";
}

