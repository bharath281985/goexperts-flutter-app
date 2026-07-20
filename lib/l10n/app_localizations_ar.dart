// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Go Experts';

  @override
  String get appName => 'Go Experts';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get logInToContinue => 'سجل الدخول للمتابعة إلى Go Experts';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get settings => 'الإعدادات';

  @override
  String get settingsUpdated => 'تم تحديث الإعدادات';

  @override
  String get account => 'الحساب';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get securityCenter => 'مركز الأمان';

  @override
  String get subscriptionBilling => 'الاشتراك والفواتير';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get currency => 'العملة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get pushNotifications => 'إشعارات الدفع';

  @override
  String get emailUpdates => 'تحديثات البريد الإلكتروني';

  @override
  String get marketing => 'التسويق';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get publicProfile => 'الملف العام';

  @override
  String get viewPublicProfile => 'عرض الملف العام';

  @override
  String get blockedUsers => 'المستخدمون المحظورون';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get support => 'الدعم';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get aboutGoExperts => 'حول Go Experts';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get guest => 'زائر';

  @override
  String get user => 'مستخدم';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get retrySync => 'إعادة محاولة المزامنة';

  @override
  String get youreOffline => 'أنت غير متصل';

  @override
  String youreOfflineQueued(Object count) {
    return 'أنت غير متصل · $count تغيير(تغييرات) في قائمة الانتظار';
  }

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get submit => 'إرسال';

  @override
  String get continueText => 'متابعة';

  @override
  String get next => 'التالي';

  @override
  String get skip => 'تخطي';

  @override
  String get later => 'لاحقاً';

  @override
  String get update => 'تحديث';

  @override
  String get ok => 'موافق';

  @override
  String get home => 'الرئيسية';

  @override
  String get projects => 'المشاريع';

  @override
  String get chats => 'المحادثات';

  @override
  String get wallet => 'المحفظة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get messages => 'الرسائل';

  @override
  String get meetings => 'الاجتماعات';

  @override
  String get bookmarks => 'الإشارات المرجعية';

  @override
  String get subscriptions => 'الاشتراكات';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get logOutQuestion => 'تسجيل الخروج؟';

  @override
  String get signInAgain => 'ستحتاج إلى تسجيل الدخول مرة أخرى.';

  @override
  String get signInAgainAccess =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى للوصول إلى حسابك.';

  @override
  String get search => 'بحث';

  @override
  String get filters => 'عوامل التصفية';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get apply => 'تطبيق';

  @override
  String get applyFilters => 'تطبيق عوامل التصفية';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get newest => 'الأحدث';

  @override
  String get budgetHighToLow => 'الميزانية: من الأعلى إلى الأدنى';

  @override
  String get budgetLowToHigh => 'الميزانية: من الأدنى إلى الأعلى';

  @override
  String get mostProposals => 'أكثر العروض';

  @override
  String get searchEllipsis => 'بحث…';

  @override
  String get noMatches => 'لا توجد نتائج مطابقة';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get showMore => 'عرض المزيد';

  @override
  String get chooseCategoryFirst => 'اختر فئة أولاً';

  @override
  String countSelected(Object count) {
    return '$count مختار';
  }

  @override
  String noSkillsFound(Object category) {
    return 'لم يتم العثور على مهارات لـ $category';
  }

  @override
  String get removedFromSaved => 'تمت الإزالة من المحفوظات';

  @override
  String get savedProject => 'مشروع محفوظ';

  @override
  String get noProjectsFound => 'لم يتم العثور على مشاريع';

  @override
  String get searchProjectsSkills => 'ابحث عن مشاريع، مهارات…';

  @override
  String get adjustSearchFilters => 'حاول تعديل بحثك أو عوامل التصفية.';

  @override
  String get subscribe => 'اشتراك';

  @override
  String get choosePlan => 'اختر خطة';

  @override
  String get chooseYourPlan => 'اختر خطتك';

  @override
  String get renewPlan => 'تجديد خطتك';

  @override
  String get viewPlans => 'عرض الخطط';

  @override
  String get noCurrentPlan => 'لا توجد خطة حالية';

  @override
  String get planFeatures => 'ميزات الخطة';

  @override
  String get planLimits => 'حدود الخطة';

  @override
  String get starterPlan => 'خطة المبتدئين';

  @override
  String get freelancerAnnualPlan => 'الخطة السنوية للمستقلين';

  @override
  String get portfolio => 'المحفظة';

  @override
  String get reviews => 'المراجعات';

  @override
  String get analytics => 'التحليلات';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get discoverProjects => 'اكتشف المشاريع';

  @override
  String get rating => 'التقييم';

  @override
  String get followers => 'المتابعون';

  @override
  String get workspace => 'مساحة العمل';

  @override
  String get freelancer => 'مستقل';

  @override
  String get client => 'عميل';

  @override
  String get clientBusinessOwner => 'عميل / صاحب عمل';

  @override
  String get business => 'أعمال';

  @override
  String get investor => 'مستثمر';

  @override
  String get founder => 'مؤسس';

  @override
  String get startupFounder => 'مؤسس شركة ناشئة';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get freelanceWorkUpdate => 'إليك ما يحدث في عملك الحر اليوم.';

  @override
  String get manageProjectsTeams => 'أدر مشاريعك وفرقك وتعييناتك في مكان واحد.';

  @override
  String get discoverStartups => 'اكتشف الشركات الناشئة';

  @override
  String get proposals => 'العروض';

  @override
  String get contracts => 'العقود';

  @override
  String get myProjects => 'مشاريعي';

  @override
  String get createProject => 'إنشاء مشروع';

  @override
  String get postNewProject => 'نشر مشروع جديد';

  @override
  String get hireFreelancers => 'توظيف مستقلين';

  @override
  String get applications => 'الطلبات';

  @override
  String get payments => 'المدفوعات';

  @override
  String get companyProfile => 'الملف الشخصي للشركة';

  @override
  String get investorProfile => 'الملف الشخصي للمستثمر';

  @override
  String get founderProfile => 'الملف الشخصي للمؤسس';

  @override
  String get dealRooms => 'غرف الصفقات';

  @override
  String get myStartup => 'شركتي الناشئة';

  @override
  String get investors => 'المستثمرون';

  @override
  String get funding => 'التمويل';

  @override
  String get talent => 'المواهب';

  @override
  String get startup => 'شركة ناشئة';

  @override
  String get deals => 'الصفقات';

  @override
  String get availableBalance => 'الرصيد المتاح';

  @override
  String get pending => 'معلق';

  @override
  String get inEscrow => 'في الحجز';

  @override
  String get lifetime => 'مدى الحياة';

  @override
  String get bank => 'البنك';

  @override
  String get upi => 'UPI';

  @override
  String get amount => 'المبلغ';

  @override
  String get enterAmount => 'أدخل المبلغ';

  @override
  String get withdraw => 'سحب';

  @override
  String get invoices => 'الفواتير';

  @override
  String get addMoney => 'إضافة أموال';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get activeProjects => 'المشاريع النشطة';

  @override
  String get pendingProposals => 'العروض المعلقة';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get monthlyEarnings => 'الأرباح الشهرية';

  @override
  String get monthlySpend => 'الإنفاق الشهري';

  @override
  String get last6Months => 'آخر 6 أشهر';

  @override
  String get upcomingMeetings => 'الاجتماعات القادمة';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get recommendedProjects => 'المشاريع الموصى بها';

  @override
  String get recommendedFreelancers => 'المستقلون الموصى بهم';

  @override
  String get projectSpending => 'إنفاق المشروع';

  @override
  String get freelancersHired => 'المستقلون المعينون';

  @override
  String get profileViews => 'مشاهدات الملف الشخصي';

  @override
  String get proposalWinRate => 'معدل فوز العروض';

  @override
  String get monthlyEarningsStats => 'الأرباح الشهرية';

  @override
  String get avgRating => 'متوسط التقييم';

  @override
  String get projectsPosted => 'المشاريع المنشورة';

  @override
  String get hireRate => 'معدل التوظيف';

  @override
  String get monthlySpendStats => 'الإنفاق الشهري';

  @override
  String get avgTimeToHire => 'متوسط وقت التوظيف';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get english => 'الإنجليزية';

  @override
  String get hindi => 'الهندية';

  @override
  String get telugu => 'التيلوغوية';

  @override
  String get tamil => 'التاميلية';

  @override
  String get kannada => 'الكانادا';

  @override
  String get malayalam => 'المالايالامية';

  @override
  String get marathi => 'الماراثية';

  @override
  String get gujarati => 'الغوجاراتية';

  @override
  String get bengali => 'البنغالية';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'الفرنسية';
}
