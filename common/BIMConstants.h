extern NSString *const kBIMBundleID;
extern NSString *const kBRConnection;

// notifications
extern NSString *const kBIMUserDefaultsDidChangeNotification;
extern NSString *const kBaramRemapperDidLaunchNotification;
extern NSString *const kBaramDictionaryAddNewWordNotification;
extern NSString *const kBaramDictionaryDidChangeNotification;

// modes
extern NSString *const kBIMEnglishMode;
extern NSString *const kBIMHangulMode;
extern NSString *const kBIMHanjaMode;
extern NSString *const kBIMHiraganaMode;
extern NSString *const kBIMKatakanaMode;

// layout names
extern NSString *const kUSKeylayout;
extern NSString *const kGermanKeylayout;
extern NSString *const kDvorakKeylayout;
extern NSString *const kDvorakQwertyKeylayout;

// Basic setup
extern NSString *const kBIMEnglishKeyboardKey;
extern NSString *const kBIMHangulKeyboardKey;
extern NSString *const kBIMHangulOrderCorrectionKey;
extern NSString *const kBIMQwertyEmulationEnableKey;

// Shortcuts
extern NSString *const kBIMShortcutsKey;
extern NSString *const kShortcutUserDefinedKey;
extern NSString *const kShortcutEnableKey;
extern NSString *const kCGEventTypeKey;
extern NSString *const kCGEventKeyCodeKey;
extern NSString *const kCGEventFlagsKey;
extern NSString *const kCGEventFlagsMaskKey;
extern NSString *const kCGEventFlagsOptionKey;
extern NSString *const kShortcutTypeKey;
extern NSString *const kShortcutStringKey;
extern NSString *const kShortcutStringIgnoringModifiersKey;
enum {
  kBIMSwitchShortcut = 0,
  kBIMHanjaShortcut,
  kBIMJapaneseShortcut,
  kBIMRomanShortcut,
  kBIMBaramDictionaryShortcut,
  kBIMReloadDictionaryShortcut,
  kBIMRegisterSelectedWordShortcut,
};

enum {
  kCGEventFlagsAny = 0,
  kCGEventFlagsLeft,
  kCGEventFlagsRight,
};

// Advanced setup
extern NSString *const kBIMHangulCommitByWordKey;
extern NSString *const kBIMEnglishBypassWithOptionKey;
extern NSString *const kBIMHanjaCommitByWordKey;
extern NSString *const kBIMHanjaParenStyleKey;
extern NSString *const kBIMVIModeKey;

extern NSString *const kBIMCandidatesPanelPropertiesKey;
extern NSString *const kBIMCandidatesPanelTypeKey;
extern NSString *const kBIMCandidatesFontSizeKey;

extern NSString *const kBIMIndicatorPropertiesKey;
extern NSString *const kBIMIndicatorEnableKey;

// Dictionary setup
extern NSString *const kBIMDisabledDictionariesKey;
extern NSString *const kBIMDictionaryEnabledKey;
extern NSString *const kBIMDictionaryFilenameKey;

extern NSString *const kBIMAttributedStringEnabledKey;
extern NSString *const kBIMFontsAttributesKey;

enum {
  kBIMDictionaryForNilMode = -1,
  kBIMDictionaryForAllMode = 0,
  kBIMDictionaryForHangulMode,
  kBIMDictionaryForRomanMode,
  kBIMDictionaryForJapaneseMode,
};

// Trigger setup
extern NSString *const kBIMTriggerPropertiesKey;
extern NSString *const kBIMTriggerEnableKey;
extern NSString *const kBIMTriggerAlertKey;
extern NSString *const kBIMTriggerChangeInputModeKey;
extern NSString *const kBIMTriggerArrayKey;

// Remapper setup
extern NSString *const kBIMAppSpecificSetupKey;

// Updater setup
extern NSString *const kBIMUpdateCheckPeriodKey;
extern NSString *const kBIMUpdateLastCheckKey;

// For developer
extern NSString *const kBIMVerboseModeKey;

#define ANYMODMASK   0xffff0000
#define LEFTMODMASK  (ANYMODMASK | NX_DEVICELCTLKEYMASK | NX_DEVICELSHIFTKEYMASK | NX_DEVICELCMDKEYMASK | NX_DEVICELALTKEYMASK)
#define RIGHTMODMASK (ANYMODMASK | NX_DEVICERCTLKEYMASK | NX_DEVICERSHIFTKEYMASK | NX_DEVICERCMDKEYMASK | NX_DEVICERALTKEYMASK)

#ifdef DEBUG
#define DLOG(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLOG(...)
#endif

#ifdef DEBUG
#define NSLog_VM(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define NSLog_VM(...)
#endif
