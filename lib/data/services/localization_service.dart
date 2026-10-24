import 'package:flutter/material.dart';

enum AppLanguage {
  en('English', 'English', '🇬🇧'),
  hi('Hindi', 'हिन्दी', '🇮🇳'),
  mr('Marathi', 'मराठी', '🇮🇳'),
  ta('Tamil', 'தமிழ்', '🇮🇳'),
  te('Telugu', 'తెలుగు', '🇮🇳'),
  bn('Bengali', 'বাংলা', '🇮🇳');

  final String name;
  final String nativeName;
  final String flag;

  const AppLanguage(this.name, this.nativeName, this.flag);
}

class LocalizationService extends ChangeNotifier {
  static final LocalizationService instance = LocalizationService._internal();
  LocalizationService._internal();

  AppLanguage _currentLanguage = AppLanguage.en;

  AppLanguage get currentLanguage => _currentLanguage;

  void setLanguage(AppLanguage lang) {
    if (_currentLanguage != lang) {
      _currentLanguage = lang;
      notifyListeners();
    }
  }

  // DICTIONARY
  static final Map<AppLanguage, Map<String, String>> _localizedValues = {
    AppLanguage.en: {
      'app_title': 'FoodBridge 2.0',
      'role_select_title': 'Choose How You Wish to Make an Impact',
      'role_select_desc':
          'Select your persona to unlock role-tailored dashboards and secure features.',
      'role_donor': 'Commercial Food Donor',
      'role_community': 'Community Giver',
      'role_ngo': 'Verified NGO / Kitchen',
      'role_admin': 'Platform Admin',
      'tag_anyone_can_give': 'ANYONE CAN GIVE • CLOTHES, BOOKS & FUNDS',
      'continue_btn': 'Continue',
      'post_surplus': 'Post Surplus Food',
      'giving_hub': 'Giving Hub',
      'donate_now': 'Donate Now',
      'impact_ledger': 'Impact Ledger & 80G',
      'fssai_verified': 'FSSAI Verified',
      'cold_chain_check': 'Cold Chain Thermal Check',
      'offline_mode': 'Offline Mode',
      'online_synced': 'Online (Cloud Synced)',
      'whatsapp_alert': 'WhatsApp Dispatch Bot',
      'esg_carbon': 'ESG & Carbon Offset',
      'live_tracking': 'Live Driver GPS',
      'ai_vision_scan': 'AI Perishability Food Scanner',
      'anonymous_giving': 'Anonymous Mode Active',
    },
    AppLanguage.hi: {
      'app_title': 'फूडब्रिज २.०',
      'role_select_title': 'चुनें कि आप कैसे योगदान देना चाहते हैं',
      'role_select_desc':
          'सुरक्षित सुविधाओं और डैशबोर्ड को अनलॉक करने के लिए अपनी भूमिका चुनें।',
      'role_donor': 'व्यावसायिक भोजन दाता',
      'role_community': 'समुदाय दानी (कपड़े, पुस्तकें व राशि)',
      'role_ngo': 'सत्यापित एनजीओ / रसोई',
      'role_admin': 'प्लेटफ़ॉर्म व्यवस्थापक',
      'tag_anyone_can_give': 'कोई भी दान कर सकता है • कपड़े, किताबें और राशि',
      'continue_btn': 'आगे बढ़ें',
      'post_surplus': 'बचा हुआ भोजन पोस्ट करें',
      'giving_hub': 'दान केंद्र',
      'donate_now': 'अभी दान करें',
      'impact_ledger': 'प्रभाव खाता व 80G रसीद',
      'fssai_verified': 'एफएसएसएआई सत्यापित',
      'cold_chain_check': 'तापमान व ताजगी परीक्षण',
      'offline_mode': 'ऑफ़लाइन मोड',
      'online_synced': 'ऑनलाइन (क्लाउड सिंक)',
      'whatsapp_alert': 'व्हाट्सएप प्रेषण बॉट',
      'esg_carbon': 'कार्बन बचत व ईएसजी मेट्रिक्स',
      'live_tracking': 'लाइव ड्राइवर जीपीएस ट्रैकर',
      'ai_vision_scan': 'एआई खाद्य गुणवत्ता स्कैनर',
      'anonymous_giving': 'गुमनाम दान सक्रिय',
    },
    AppLanguage.mr: {
      'app_title': 'फूडब्रिज २.०',
      'role_select_title': 'आपण कसा प्रभाव पाडू इच्छिता ते निवडा',
      'role_select_desc':
          'आपल्या गरजेनुसार डॅशबोर्ड अनलॉक करण्यासाठी भूमिका निवडा.',
      'role_donor': 'अन्न दाता (हॉटेल/कॅटरर्स)',
      'role_community': 'समुदाय दाता (कपडे, पुस्तके व निधी)',
      'role_ngo': 'प्रमाणित स्वयंसेवी संस्था / निवारा',
      'role_admin': 'प्लॅटफॉर्म प्रशासक',
      'tag_anyone_can_give': 'कोणीही दान करू शकते • कपडे, पुस्तके आणि निधी',
      'continue_btn': 'पुढे सुरू ठेवा',
      'post_surplus': 'अतिरिक्त अन्न पोस्ट करा',
      'giving_hub': 'दान केंद्र',
      'donate_now': 'आता दान करा',
      'impact_ledger': 'प्रभाव लेजर व 80G पावती',
      'fssai_verified': 'FSSAI प्रमाणित',
      'cold_chain_check': 'अन्न तापमान तपासणी',
      'offline_mode': 'ऑफलाइन मोड',
      'online_synced': 'ऑनलाइन (क्लाउड समक्रमित)',
      'whatsapp_alert': 'व्हॉट्सअ‍ॅप डिस्पॅच बॉट',
      'esg_carbon': 'कार्बन बचत आणि ईएसजी अहवाल',
      'live_tracking': 'थेट वाहन ट्रॅकिंग',
      'ai_vision_scan': 'एआय अन्न गुणवत्ता स्कॅनर',
      'anonymous_giving': 'अनामिक देणगी मोड',
    },
    AppLanguage.ta: {
      'app_title': 'ஃபுட்பிரிட்ஜ் 2.0',
      'role_select_title': 'உங்களின் பங்களிப்பைத் தேர்வுசெய்யவும்',
      'role_select_desc':
          'தனிப்பயனாக்கப்பட்ட வசதிகளைப் பெற உங்கள் பங்களிப்பைத் தேர்ந்தெடுக்கவும்.',
      'role_donor': 'உணவு வழங்குநர்',
      'role_community': 'சமூக கொடையாளர் (ஆடை, புத்தகங்கள்)',
      'role_ngo': 'சரிபார்க்கப்பட்ட என்.ஜி.ஓ',
      'role_admin': 'நிர்வாகி',
      'tag_anyone_can_give':
          'யாரும் உதவலாம் • உடைகள், புத்தகங்கள் மற்றும் நிதி',
      'continue_btn': 'தொடரவும்',
      'post_surplus': 'உணவை பதிவு செய்யவும்',
      'giving_hub': 'கொடை மையம்',
      'donate_now': 'இப்போது வழங்கவும்',
      'impact_ledger': '80G வரி ரசீது',
      'fssai_verified': 'FSSAI சரிபார்க்கப்பட்டது',
      'cold_chain_check': 'வெப்பநிலை சோதனை',
      'offline_mode': 'ஆஃப்லைன் முறை',
      'online_synced': 'ஆன்லைன் (இணைக்கப்பட்டது)',
      'whatsapp_alert': 'வாட்ஸ்அப் போட்',
      'esg_carbon': 'கார்பன் சேமிப்பு அறிக்கை',
      'live_tracking': 'நேரலை ஜிபிஎஸ் டிராக்கிங்',
      'ai_vision_scan': 'AI உணவு ஸ்கேனர்',
      'anonymous_giving': 'பெயரற்ற கொடை',
    },
    AppLanguage.te: {
      'app_title': 'ఫుడ్‌బ్రిడ్జ్ 2.0',
      'role_select_title': 'మీరు ఎలా సహాయం చేయాలనుకుంటున్నారో ఎంచుకోండి',
      'role_select_desc':
          'మీకు సరిపోయే డ్యాష్‌బోర్డ్ తెరవడానికి పాత్రను ఎంచుకోండి.',
      'role_donor': 'ఆహార దాత (హోటళ్ళు & క్యాటరర్లు)',
      'role_community': 'కమ్యూనిటీ దాత (బట్టలు, పుస్తకాలు & నిధులు)',
      'role_ngo': 'ధృవీకరించబడిన ఎన్జీవో',
      'role_admin': 'ప్లాట్‌ఫారమ్ అడ్మిన్',
      'tag_anyone_can_give':
          'ఎవరైనా సహాయం చేయవచ్చు • బట్టలు, పుస్తకాలు & నిధులు',
      'continue_btn': 'కొనసాగించండి',
      'post_surplus': 'మిగిలిన ఆహారాన్ని పోస్ట్ చేయండి',
      'giving_hub': 'సహాయ కేంద్రం',
      'donate_now': 'ఇప్పుడే దానం చేయండి',
      'impact_ledger': '80G రశీదు & ప్రభావం',
      'fssai_verified': 'FSSAI ధృవీకరించబడింది',
      'cold_chain_check': 'ఆహార ఉష్ణోగ్రత తనిఖీ',
      'offline_mode': 'ఆఫ్‌లైన్ మోడ్',
      'online_synced': 'ఆన్‌లైన్ (సింక్ చేయబడింది)',
      'whatsapp_alert': 'వాట్సాప్ అలర్ట్ బాట్',
      'esg_carbon': 'కార్బన్ తగ్గింపు రిపోర్ట్',
      'live_tracking': 'లైవ్ జీపీఎస్ ట్రాకింగ్',
      'ai_vision_scan': 'AI ఆహార స్కానర్',
      'anonymous_giving': 'అజ్ఞాత దానం',
    },
    AppLanguage.bn: {
      'app_title': 'ফুডব্রিজ ২.০',
      'role_select_title': 'আপনার অবদানের ধরণ নির্বাচন করুন',
      'role_select_desc':
          'আপনার প্রয়োজন অনুযায়ী ড্যাশবোর্ড ব্যবহার করতে ভূমিকা বেছে নিন।',
      'role_donor': 'খাবার দাতা',
      'role_community': 'কমিউনিটি দাতা (পোশাক, বই ও অনুদান)',
      'role_ngo': 'যাচাইকৃত এনজিও',
      'role_admin': 'প্ল্যাটফর্ম অ্যাডমিন',
      'tag_anyone_can_give': 'যে কেউ দিতে পারে • জামাকাপড়, বই ও তহবিল',
      'continue_btn': 'এগিয়ে যান',
      'post_surplus': 'উদ্বৃত্ত খাবার পোস্ট করুন',
      'giving_hub': 'দান কেন্দ্র',
      'donate_now': 'এখনই দান করুন',
      'impact_ledger': '৮০জি কর ছাড়ের রসিদ',
      'fssai_verified': 'এফএসএসএআই প্রত্যয়িত',
      'cold_chain_check': 'খাবারের তাপমাত্রা পরীক্ষা',
      'offline_mode': 'অফলাইন মোড',
      'online_synced': 'অনলাইন (সিঙ্ক করা)',
      'whatsapp_alert': 'হোয়াটসঅ্যাপ অ্যালার্ট বট',
      'esg_carbon': 'কার্বন হ্রাস বিশ্লেষণ',
      'live_tracking': 'লাইভ ড্রাইভার জিপিএস',
      'ai_vision_scan': 'এআই খাদ্য স্ক্যানার',
      'anonymous_giving': 'বেনামী অনুদান',
    },
  };

  String tr(String key) {
    return _localizedValues[_currentLanguage]?[key] ??
        _localizedValues[AppLanguage.en]?[key] ??
        key;
  }
}
