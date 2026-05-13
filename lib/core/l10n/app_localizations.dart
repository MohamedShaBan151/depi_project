import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  bool get isArabic => locale.languageCode == 'ar';

  static const _ar = <String, String>{
    'app_name': 'نون',
    'home': 'الرئيسية',
    'search': 'بحث',
    'cart': 'السلة',
    'account': 'حسابي',
    'welcome': 'مرحباً بعودتك',
    'sign_in': 'تسجيل دخول',
    'sign_up': 'إنشاء حساب',
    'sign_out': 'تسجيل خروج',
    'add_to_cart': 'أضف للسلة',
    'wishlist': 'المفضلة',
    'total': 'الإجمالي',
    'checkout': 'إتمام الطلب',
    'orders': 'طلباتي',
    'addresses': 'عناويني',
    'settings': 'الإعدادات',
    'categories': 'الأقسام',
    'free_shipping': 'شحن مجاني',
    'fast_delivery': 'توصيل سريع',
    'secure_payment': 'دفع آمن',
    'support_247': 'دعم 24/7',
    'no_orders': 'لا توجد طلبات بعد',
    'no_cart_items': 'السلة فارغة',
    'no_results': 'لا توجد نتائج',
    'search_hint': 'ابحث عن المنتجات...',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'forgot_password': 'نسيت كلمة المرور؟',
    'login': 'تسجيل الدخول',
    'logout': 'تسجيل الخروج',
    'register': 'إنشاء حساب',
    'all': 'الكل',
    'settings_notifications': 'الإشعارات',
    'settings_language': 'اللغة',
    'settings_help': 'المساعدة والدعم',
    'settings_about': 'حول',
    'order_placed': 'تم تأكيد الطلب',
    'track_order': 'تتبع الطلب',
    'continue_shopping': 'متابعة التسوق',
    'buy_again': 'اشترِ مرة أخرى',
    'delete': 'حذف',
    'edit': 'تعديل',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'apply': 'تطبيق',
    'coupon': 'كود الخصم',
    'discount': 'الخصم',
    'subtotal': 'المجموع الفرعي',
    'delivery_fee': 'رسوم التوصيل',
    'payment_method': 'طريقة الدفع',
    'cod': 'الدفع عند الاستلام',
    'card': 'بطاقة ائتمان',
    'address': 'العنوان',
    'add_address': 'إضافة عنوان',
    'default': 'افتراضي',
  };

  static const _en = <String, String>{
    'app_name': 'Noon',
    'home': 'Home',
    'search': 'Search',
    'cart': 'Cart',
    'account': 'Account',
    'welcome': 'Welcome back',
    'sign_in': 'Sign In',
    'sign_up': 'Sign Up',
    'sign_out': 'Sign Out',
    'add_to_cart': 'Add to Cart',
    'wishlist': 'Wishlist',
    'total': 'Total',
    'checkout': 'Checkout',
    'orders': 'Orders',
    'addresses': 'Addresses',
    'settings': 'Settings',
    'categories': 'Categories',
    'free_shipping': 'Free Shipping',
    'fast_delivery': 'Fast Delivery',
    'secure_payment': 'Secure Payment',
    'support_247': '24/7 Support',
    'no_orders': 'No orders yet',
    'no_cart_items': 'Your cart is empty',
    'no_results': 'No results found',
    'search_hint': 'Search products...',
    'email': 'Email',
    'password': 'Password',
    'forgot_password': 'Forgot password?',
    'login': 'Login',
    'logout': 'Logout',
    'register': 'Register',
    'all': 'All',
    'settings_notifications': 'Notifications',
    'settings_language': 'Language',
    'settings_help': 'Help & Support',
    'settings_about': 'About',
    'order_placed': 'Order Placed',
    'track_order': 'Track Order',
    'continue_shopping': 'Continue Shopping',
    'buy_again': 'Buy Again',
    'delete': 'Delete',
    'edit': 'Edit',
    'save': 'Save',
    'cancel': 'Cancel',
    'apply': 'Apply',
    'coupon': 'Coupon Code',
    'discount': 'Discount',
    'subtotal': 'Subtotal',
    'delivery_fee': 'Delivery Fee',
    'payment_method': 'Payment Method',
    'cod': 'Cash on Delivery',
    'card': 'Credit Card',
    'address': 'Address',
    'add_address': 'Add Address',
    'default': 'Default',
  };

  String translate(String key) {
    if (isArabic) {
      return _ar[key] ?? key;
    }
    return _en[key] ?? key;
  }

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(Localizations.localeOf(context));
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'ar';

  @override
  Future<AppLocalizations> load(Locale locale) =>
      Future.value(AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
