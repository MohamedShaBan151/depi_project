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
    // Reviews & Ratings
    'reviews': 'التقييمات',
    'add_review': 'إضافة تقييم',
    'rating': 'التقييم',
    'review': 'التقييم',
    'your_review': 'تقييمك',
    'submit_review': 'إرسال التقييم',
    'no_reviews': 'لا توجد تقييمات بعد',
    'verified_purchase': 'شراء تم التحقق منه',
    // Wishlist
    'add_to_wishlist': 'إضافة للمفضلة',
    'remove_from_wishlist': 'إزالة من المفضلة',
    'no_wishlist_items': 'المفضلة فارغة',
    // Returns & Refunds
    'returns': 'المرتجعات',
    'request_return': 'طلب استرجاع',
    'return_reason': 'سبب الاسترجاع',
    'return_status': 'حالة الاسترجاع',
    'refund_status': 'حالة استرجاع المبلغ',
    'return_pending': 'في الانتظار',
    'return_approved': 'تمت الموافقة',
    'return_shipped': 'تم الإرسال',
    'return_received': 'تم الاستقبال',
    'return_refunded': 'تم استرجاع المبلغ',
    'no_returns': 'لا توجد طلبات استرجاع',
    // Network & Errors
    'network_error': 'خطأ في الاتصال',
    'no_internet': 'لا يوجد اتصال بالإنترنت',
    'retry': 'إعادة محاولة',
    'error_loading': 'خطأ في تحميل البيانات',
    'error_saving': 'خطأ في حفظ البيانات',
    'error_deleting': 'خطأ في حذف البيانات',
    'success': 'نجح',
    'loading': 'جاري التحميل...',
    // Pagination
    'load_more': 'تحميل المزيد',
    'showing': 'عرض',
    'of': 'من',
    'products': 'منتجات',
    // Support & Help
    'help_support': 'المساعدة والدعم',
    'faq': 'الأسئلة الشائعة',
    'contact_us': 'اتصل بنا',
    'phone': 'الهاتف',
    'live_chat': 'دردشة فورية',
    'email_support': 'البريد الإلكتروني',
    // Analytics
    'privacy_policy': 'سياسة الخصوصية',
    'terms_conditions': 'شروط وأحكام',
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
    // Reviews & Ratings
    'reviews': 'Reviews',
    'add_review': 'Add Review',
    'rating': 'Rating',
    'review': 'Review',
    'your_review': 'Your Review',
    'submit_review': 'Submit Review',
    'no_reviews': 'No reviews yet',
    'verified_purchase': 'Verified Purchase',
    // Wishlist
    'add_to_wishlist': 'Add to Wishlist',
    'remove_from_wishlist': 'Remove from Wishlist',
    'no_wishlist_items': 'Your wishlist is empty',
    // Returns & Refunds
    'returns': 'Returns',
    'request_return': 'Request Return',
    'return_reason': 'Return Reason',
    'return_status': 'Return Status',
    'refund_status': 'Refund Status',
    'return_pending': 'Pending',
    'return_approved': 'Approved',
    'return_shipped': 'Shipped',
    'return_received': 'Received',
    'return_refunded': 'Refunded',
    'no_returns': 'No returns yet',
    // Network & Errors
    'network_error': 'Network Error',
    'no_internet': 'No internet connection',
    'retry': 'Retry',
    'error_loading': 'Error loading data',
    'error_saving': 'Error saving data',
    'error_deleting': 'Error deleting data',
    'success': 'Success',
    'loading': 'Loading...',
    // Pagination
    'load_more': 'Load More',
    'showing': 'Showing',
    'of': 'of',
    'products': 'products',
    // Support & Help
    'help_support': 'Help & Support',
    'faq': 'FAQ',
    'contact_us': 'Contact Us',
    'phone': 'Phone',
    'live_chat': 'Live Chat',
    'email_support': 'Email Support',
    // Analytics
    'privacy_policy': 'Privacy Policy',
    'terms_conditions': 'Terms & Conditions',
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
