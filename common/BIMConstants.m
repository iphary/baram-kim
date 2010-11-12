NSString *const kBIMBundleID = @"kr.or.baram.inputmethod.Baram";
NSString *const kBRConnection = @"baram_remapper_connection";

// notifications
NSString *const kBIMUserDefaultsDidChangeNotification = @"BIMUserDefaultsDidChangeNotification";
NSString *const kBaramRemapperDidLaunchNotification = @"BaramRemapperDidLaunchNotification"; 
NSString *const kBaramDictionaryAddNewWordNotification = @"BaramDictionaryAddNewWordNotification";
NSString *const kBaramDictionaryDidChangeNotification = @"BaramDictionaryDidChangeNotification";

// modes
NSString *const kBIMEnglishMode  = @"kr.or.baram.inputmethod.Baram.english";
NSString *const kBIMHangulMode   = @"kr.or.baram.inputmethod.Baram.hangul";
NSString *const kBIMHiraganaMode = @"kr.or.baram.inputmethod.Baram.hiragana";
NSString *const kBIMKatakanaMode = @"kr.or.baram.inputmethod.Baram.katakana";

// layout names
NSString *const kUSKeylayout           = @"com.apple.keylayout.US";
NSString *const kGermanKeylayout       = @"com.apple.keylayout.German";
NSString *const kDvorakKeylayout       = @"com.apple.keylayout.Dvorak";
NSString *const kDvorakQwertyKeylayout = @"com.apple.keylayout.DVORAK-QWERTYCMD";

// Basic setup
NSString *const kBIMEnglishKeyboardKey                       = @"BIMEnglishKeyboard";
NSString *const kBIMHangulKeyboardKey                        = @"BIMHangulKeyboard";
NSString *const kBIMHangulOrderCorrectionKey                 = @"BIMHangulOrderCorrection";

// Shortcuts
NSString *const kBIMShortcutsKey                             = @"BIMShortcuts";
NSString *const kShortcutUserDefinedKey                      = @"userDefined";
NSString *const kShortcutEnableKey                           = @"enable";
NSString *const kCGEventTypeKey                              = @"CGEventType";
NSString *const kCGEventKeyCodeKey                           = @"CGEventKeyCode";
NSString *const kCGEventFlagsKey                             = @"CGEventFlags";
NSString *const kCGEventFlagsMaskKey                         = @"CGEventFlagsMask";
NSString *const kCGEventFlagsOptionKey                       = @"CGEventFlagsOption";
NSString *const kShortcutTypeKey                             = @"type";
NSString *const kShortcutStringKey                           = @"string";
NSString *const kShortcutStringIgnoringModifiersKey          = @"stringIgnoringModifiers";

// Advanced setup
NSString *const kBIMHangulCommitByWordKey                    = @"BIMHangulCommitByWord";
NSString *const kBIMEnglishBypassWithOptionKey               = @"BIMEnglishBypassWithOption";
NSString *const kBIMHanjaCommitByWordKey                     = @"BIMHanjaCommitByWord";
NSString *const kBIMHanjaParenStyleKey                       = @"BIMHanjaParenStyle";

NSString *const kBIMCandidatesPanelPropertiesKey             = @"BIMCandidatesPanel";
NSString *const kBIMCandidatesPanelTypeKey                   = @"PanelType";
NSString *const kBIMCandidatesFontSizeKey                    = @"FontSize";
NSString *const kBIMVIModeKey                                = @"VIMode";

// Indicator
NSString *const kBIMIndicatorPropertiesKey                   = @"BIMIndicator";
NSString *const kBIMIndicatorEnableKey                       = @"enable";

// Dictionary setup
NSString *const kBIMDisabledDictionariesKey                  = @"BIMDisabledDictionaries";
NSString *const kBIMDictionaryEnabledKey                     = @"enable";
NSString *const kBIMDictionaryFilenameKey                    = @"filename";

// Trigger setup
NSString *const kBIMTriggerPropertiesKey                     = @"BIMTrigger";
NSString *const kBIMTriggerEnableKey                         = @"enable";
NSString *const kBIMTriggerAlertKey                          = @"alert";
NSString *const kBIMTriggerChangeInputModeKey                = @"changeInputMode";
NSString *const kBIMTriggerArrayKey                          = @"tiggers";

// Remapper setup
NSString *const kBIMAppSpecificSetupKey                      = @"BIMApplicationSpecificSetup";

// Updater setup
NSString *const kBIMUpdateCheckPeriodKey                     = @"BIMUpdateCheckPeriod";
NSString *const kBIMUpdateLastCheckKey                       = @"BIMLastCheck";

NSString *const kBIMAttributedStringEnabledKey               = @"attributedStringEnabled";
NSString *const kBIMFontsAttributesKey                       = @"fontsAttributes";

// For developer
NSString *const kBIMVerboseModeKey                           = @"BIMVerboseMode";
