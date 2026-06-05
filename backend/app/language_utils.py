"""
language_utils.py
-----------------
Language detection + prompt templates for each supported Indian language.
"""

from langdetect import detect, LangDetectException
import logging

logger = logging.getLogger(__name__)

# Prompt instructions in each language
PROMPTS = {
    "hi": (
        "नीचे दी गई चैट का संक्षिप्त सारांश हिंदी में लिखें। "
        "मुख्य विषय, महत्वपूर्ण बातें और निर्णय शामिल करें।\n\n"
        "चैट:\n{chat}\n\nसारांश:"
    ),
    "bn": (
        "নিচের চ্যাটের একটি সংক্ষিপ্ত সারাংশ বাংলায় লিখুন। "
        "মূল বিষয়, গুরুত্বপূর্ণ তথ্য এবং সিদ্ধান্ত অন্তর্ভুক্ত করুন।\n\n"
        "চ্যাট:\n{chat}\n\nসারাংশ:"
    ),
    "ta": (
        "கீழே உள்ள அரட்டையின் சுருக்கத்தை தமிழில் எழுதுங்கள். "
        "முக்கிய தலைப்புகள், முக்கியமான தகவல்கள் மற்றும் முடிவுகளை சேர்க்கவும்.\n\n"
        "அரட்டை:\n{chat}\n\nசுருக்கம்:"
    ),
    "te": (
        "దిగువ చాట్ యొక్క సంక్షిప్త సారాంశాన్ని తెలుగులో రాయండి. "
        "ముఖ్యమైన అంశాలు, సమాచారం మరియు నిర్ణయాలను చేర్చండి.\n\n"
        "చాట్:\n{chat}\n\nసారాంశం:"
    ),
    "mr": (
        "खालील चॅटचा थोडक्यात सारांश मराठीत लिहा. "
        "मुख्य विषय, महत्त्वाच्या गोष्टी आणि निर्णय समाविष्ट करा.\n\n"
        "चॅट:\n{chat}\n\nसारांश:"
    ),
    "gu": (
        "નીચે આપેલ ચેટનો સંક્ષિપ્ત સારાંશ ગુજરાતીમાં લખો. "
        "મુખ્ય વિષયો, મહત્ત્વની વિગતો અને નિર્ણયો સામેલ કરો.\n\n"
        "ચેટ:\n{chat}\n\nસારાંશ:"
    ),
    "kn": (
        "ಕೆಳಗಿನ ಚಾಟ್‌ನ ಸಂಕ್ಷಿಪ್ತ ಸಾರಾಂಶವನ್ನು ಕನ್ನಡದಲ್ಲಿ ಬರೆಯಿರಿ. "
        "ಮುಖ್ಯ ವಿಷಯಗಳು, ಪ್ರಮುಖ ಮಾಹಿತಿ ಮತ್ತು ನಿರ್ಧಾರಗಳನ್ನು ಸೇರಿಸಿ.\n\n"
        "ಚಾಟ್:\n{chat}\n\nಸಾರಾಂಶ:"
    ),
    "ml": (
        "താഴെ നൽകിയ ചാറ്റിന്റെ സംക്ഷിപ്ത സംഗ്രഹം മലയാളത്തിൽ എഴുതുക. "
        "പ്രധാന വിഷയങ്ങൾ, പ്രധാനപ്പെട്ട വിവരങ്ങൾ, തീരുമാനങ്ങൾ എന്നിവ ഉൾപ്പെടുത്തുക.\n\n"
        "ചാറ്റ്:\n{chat}\n\nസംഗ്രഹം:"
    ),
    "en": (
        "Summarize the following chat conversation concisely. "
        "Include the main topics, key points, and any decisions made.\n\n"
        "Chat:\n{chat}\n\nSummary:"
    ),
}

DEFAULT_PROMPT = PROMPTS["en"]


def detect_language(text: str) -> str:
    """Detect language of text, defaulting to English on failure."""
    try:
        lang = detect(text)
        logger.info(f"Detected language: {lang}")
        # Map some common codes
        mapping = {"zh-cn": "zh", "zh-tw": "zh"}
        return mapping.get(lang, lang)
    except LangDetectException:
        logger.warning("Language detection failed, defaulting to English")
        return "en"


def get_prompt(chat_text: str, lang_code: str) -> str:
    """Return the appropriate prompt template filled with chat text."""
    template = PROMPTS.get(lang_code, DEFAULT_PROMPT)
    # Truncate to ~1500 chars to stay within context window safely
    truncated = chat_text[:1500]
    return template.format(chat=truncated)
