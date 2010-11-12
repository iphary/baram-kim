//
//  JapaneseEngine.m
//  JapaneseEngine
//
//  Created by Ha-young Jeong on 08. 11. 11.
//  Copyright 2008 연세대 프로세서 연구실. All rights reserved.
//

#import "JapaneseEngine.h"
#import "hangul.h"
#import "../common/BIMConstants.h"
#import "../common/utf32.h"

@implementation JapaneseEngine

- (NSDictionary *)hepburnTable
{
  return 
    [NSDictionary 
      dictionaryWithObjectsAndKeys:
	/* 아 행 */
	@"a", @"아", @"i", @"이", @"u", @"우", @"e",  @"에", @"e",  @"애", @"o", @"오",
      @"xa", @"-아", @"xi", @"-이", @"xu", @"-우", @"xe", @"-에", @"xe", @"-애", @"xo", @"-오",
      @"ye", @"예",
      /* 가 행 */
      @"ka", @"카", @"ki", @"키", @"ku", @"쿠", @"ke", @"케", @"ke", @"캐", @"ko", @"코", 
      @"ka", @"까", @"ki", @"끼", @"ku", @"꾸", @"ke", @"께", @"ke", @"깨", @"ko", @"꼬", 
      @"xka", @"-카", @"xka", @"-까", @"xke", @"-케", @"xke", @"-캐", @"xke", @"-께", @"xke", @"-깨", 
      @"ga", @"가", @"gi", @"기", @"gu", @"구", @"ge", @"게", @"ge", @"개", @"go", @"고",
      @"kya", @"캬", @"kyu", @"큐", @"kyo", @"쿄",
      @"gya", @"갸", @"gyu", @"규", @"gyo", @"교",
      /* 사 행 */
      @"sa", @"사", @"si", @"시", @"su", @"수", @"su", @"쑤", @"su", @"스", @"se", @"세", @"se", @"새", @"so", @"소", 
      @"sya", @"샤", @"syu", @"슈", @"syo", @"쇼",
      @"za", @"자", @"zi", @"지", @"zu", @"즈", @"zu", @"주", @"ze", @"제", @"ze", @"재", @"zo", @"조",
      @"zya", @"쟈", @"zyu", @"쥬", @"zyo", @"죠",
      /* 다 행 */
      @"ta", @"타", @"ti", @"치", @"tu", @"츠", @"te", @"테", @"te", @"태", @"to", @"토",
      @"ta", @"따", @"ta", @"따", @"ti", @"찌", @"tu", @"쯔", @"te", @"떼", @"te", @"때", @"to", @"또",
      @"tya", @"챠", @"tyu", @"츄", @"tyo", @"쵸",
      @"xtu", @"-츠", @"xtu", @"ㄱ", @"xtu", @"ㅂ", @"xtu", @"ㅅ",
      @"da", @"다", @"di", @"디", @"du", @"드", @"du", @"두", @"de", @"데", @"de", @"대", @"do", @"도",
      /* 나 행 */
      @"na", @"나", @"ni", @"니", @"nu", @"누", @"ne", @"네", @"ne", @"내", @"no", @"노",
      /* 하 행 */
      @"ha", @"하", @"hi", @"히", @"hu", @"후", @"he", @"헤", @"he", @"해", @"ho", @"호",
      @"ba", @"바", @"bi", @"비", @"bu", @"부", @"be", @"베", @"be", @"배", @"bo", @"보",
      @"pa", @"파", @"pi", @"피", @"pu", @"푸", @"pe", @"페", @"pe", @"패", @"po", @"포",
      @"hya", @"햐", @"hyu", @"휴", @"hyo", @"효",
      @"bya", @"뱌", @"byu", @"뷰", @"byo", @"뵤",
      @"pya", @"퍄", @"pyu", @"퓨", @"pyo", @"표",
      @"va", @"-바", @"vi", @"-비", @"vu", @"-부", @"ve", @"-베",  @"ve", @"-배", @"vo", @"-보",
      @"vya", @"-뱌", @"vyu", @"-뷰", @"vyo", @"-뵤",
      /* 마 행 */
      @"ma", @"마", @"mi", @"미", @"mu", @"무", @"me", @"메", @"me", @"매", @"mo", @"모",
      @"mya", @"먀", @"myu", @"뮤", @"myo", @"묘",
      /* 야 행 */
      @"ya", @"야", @"yu", @"유", @"yo", @"요",
      @"xya", @"-야", @"xyu", @"-유", @"xyo", @"-요",
      /* 라 행 */
      @"ra", @"라", @"ri", @"리", @"ru", @"루", @"ru", @"르", @"re", @"레", @"re", @"래", @"ro", @"로",
      @"rya", @"랴", @"ryu", @"류", @"ryo", @"료",
      /* 와 행 */
      @"wa", @"와", @"wo", @"워", @"wo", @"=오", 
      @"nn", @"응", @"nn", @"ㄴ", @"nn", @"ㅇ", @"nn", @"ㅁ",
      @"xwa", @"-와", nil];
}

- (NSDictionary *)hiraganaTable
{
  return 
    [NSDictionary 
      dictionaryWithObjectsAndKeys:
	/* あ 행 */
	@"あ", @"a", @"い", @"i", @"う", @"u", @"え",  @"e", @"お", @"o",
      @"ぁ", @"xa", @"ぃ", @"xi", @"ぅ", @"xu", @"ぇ", @"xe", @"ぉ", @"xo",
      @"いぇ", @"ye",
      /* か 행 */
      @"か", @"ka", @"き", @"ki", @"く", @"ku", @"け", @"ke", @"こ", @"ko", 
      @"ヵ", @"xka", @"ヶ", @"xke",
      @"が", @"ga", @"ぎ", @"gi", @"ぐ", @"gu", @"げ", @"ge", @"ご", @"go",
      @"きゃ", @"kya", @"きぃ", @"kyi", @"きゅ", @"kyu", @"きぇ", @"kye", @"きょ", @"kyo",
      @"くゃ", @"qya", @"くゅ", @"qyu", @"くょ", @"qyo",
      @"くぁ", @"qwa", @"くぃ", @"qwi", @"くぅ", @"qwo", @"くぇ", @"qwe", @"くぉ", @"qwo",
      @"ぎゃ", @"gya", @"ぎぃ", @"gyi", @"ぎゅ", @"gyu", @"ぎぇ", @"qye", @"ぎょ", @"gyo",
      @"ぐぁ", @"gwa", @"ぐぃ", @"gwi", @"ぐぅ", @"gwu", @"ぐぇ", @"gwe", @"ぐぉ", @"gwo",
      /* さ 행 */
      @"さ", @"sa", @"し", @"si", @"す", @"su", @"せ", @"se", @"そ", @"so", 
      @"ざ", @"za", @"じ", @"zi", @"ず", @"zu", @"ぜ", @"ze", @"ぞ", @"zo",
      @"しゃ", @"sya", @"しぃ", @"syi", @"しゅ", @"syu", @"しぇ", @"sye", @"しょ", @"syo",
      @"すぁ", @"swa", @"すぃ", @"swi", @"すぅ", @"swu", @"すぇ", @"swe", @"すぉ", @"swo",
      @"じゃ", @"zya", @"じぃ", @"zyi", @"じゅ", @"zyu", @"じぇ", @"zye", @"じょ", @"zyo",
      /* た 행 */
      @"た", @"ta", @"ち", @"ti", @"つ", @"tu", @"て", @"te", @"と", @"to",
      @"っ", @"xtu",
      @"だ", @"da", @"ぢ", @"di", @"づ", @"du", @"で", @"de", @"ど", @"do",
      @"ちゃ", @"tya", @"ちぃ", @"tyi", @"ちゅ", @"tyu", @"ちぇ", @"tye", @"ちょ", @"tyo",
      @"つぁ", @"tsa", @"つぃ", @"tsi", @"つぇ", @"tse", @"つぉ", @"tso",
      @"てゃ", @"tha", @"てぃ", @"thi", @"てゅ", @"thu", @"てぇ", @"the", @"てょ", @"tho",
      @"とぁ", @"twa", @"とぃ", @"twi", @"とぅ", @"twu", @"とぇ", @"twe", @"とぉ", @"two",
      @"ぢゃ", @"dya", @"ぢぃ", @"dyi", @"ぢゅ", @"dyu", @"ぢぇ", @"dye", @"ぢょ", @"dyo",
      @"でゃ", @"dha", @"でぃ", @"dhi", @"でゅ", @"dhu", @"でぇ", @"dhe", @"でょ", @"dho",
      @"どぁ", @"dwa", @"どぃ", @"dwi", @"どぅ", @"dwu", @"どぇ", @"dwe", @"どぉ", @"dwo",
      /* な 행 */
      @"な", @"na", @"に", @"ni", @"ぬ", @"nu", @"ね", @"ne", @"の", @"no",
      @"にゃ", @"nya", @"にぃ", @"nyi", @"にゅ", @"nyu", @"にぇ", @"nye", @"にょ", @"nyo",
      /* は 행 */
      @"は", @"ha", @"ひ", @"hi", @"ふ", @"hu", @"へ", @"he", @"ほ", @"ho",
      @"ば", @"ba", @"び", @"bi", @"ぶ", @"bu", @"べ", @"be", @"ぼ", @"bo",
      @"ぱ", @"pa", @"ぴ", @"pi", @"ぷ", @"pu", @"ペ", @"pe", @"ぽ", @"po",
      @"ひゃ", @"hya", @"ひぃ", @"hyi", @"ひゅ", @"hyu", @"ひぇ", @"hye", @"ひょ", @"hyo",
      @"ふゃ", @"fya", @"ふゅ", @"fyu", @"ふょ", @"fyo",
      @"ふぁ", @"fwa", @"ふぃ", @"fwi", @"ふぅ", @"fwu", @"ふぇ", @"fwe", @"ふぉ", @"fwo",
      @"びゃ", @"bya", @"びぃ", @"byi", @"びゅ", @"byu", @"びぇ", @"bye", @"びょ", @"byo",
      @"ヴぁ", @"va", @"ヴぃ", @"vi", @"ヴ", @"vu", @"ヴぇ", @"ve", @"ヴぉ", @"vo",
      @"ヴゃ", @"vya", @"ヴぃ", @"vyi", @"ヴゅ", @"vyu", @"ヴぇ", @"vye", @"ヴょ", @"vyo",
      @"ぴゃ", @"pya", @"ぴぃ", @"pyi", @"ぴゅ", @"pyu", @"ぴぇ", @"pye", @"ぴょ", @"pyo",
      /* ま 행 */
      @"ま", @"ma", @"み", @"mi", @"む", @"mu", @"め", @"me", @"も", @"mo",
      @"みゃ", @"mya", @"みぃ", @"myi", @"みゅ", @"myu", @"みぇ", @"mye", @"みょ", @"myo",
      /* や 행 */
      @"や", @"ya", @"ゆ", @"yu", @"よ", @"yo",
      @"ゃ", @"xya", @"ゅ", @"xyu", @"ょ", @"xyo",
      /* ら 행 */
      @"ら", @"ra", @"り", @"ri", @"る", @"ru", @"れ", @"re", @"ろ", @"ro",
      @"りゃ", @"rya", @"りぃ", @"ryi", @"りゅ", @"ryu", @"りぇ", @"rye", @"りょ", @"ryo",
      /* わ 행 */
      @"わ", @"wa", @"を", @"wo", 
      @"ゎ", @"xwa", @"ん", @"nn", nil];
}

- (NSDictionary *)katakanaTable
{
  return 
    [NSDictionary 
      dictionaryWithObjectsAndKeys:
	/* ア 행 */
	@"ア", @"a", @"イ", @"i", @"ウ", @"u", @"エ",  @"e", @"オ", @"o",
      @"ァ", @"xa", @"ィ", @"xi", @"ゥ", @"xu", @"ェ", @"xe", @"ォ", @"xo",
      @"イェ", @"ye",
      /* カ 행 */
      @"カ", @"ka", @"キ", @"ki", @"ク", @"ku", @"ケ", @"ke", @"コ", @"ko", 
      @"ヵ", @"xka", @"ヶ", @"xke",
      @"ガ", @"ga", @"ギ", @"gi", @"グ", @"gu", @"ゲ", @"ge", @"ゴ", @"go",
      @"キャ", @"kya", @"キィ", @"kyi", @"キュ", @"kyu", @"キェ", @"kye", @"キョ", @"kyo",
      @"ギャ", @"gya", @"ギィ", @"gyi", @"ギュ", @"gyu", @"ギェ", @"qye", @"ギョ", @"gyo",
      @"グァ", @"gwa", @"グィ", @"gwi", @"グゥ", @"gwu", @"グェ", @"gwe", @"グォ", @"gwo",
      /* サ 행 */
      @"サ", @"sa", @"シ", @"si", @"ス", @"su", @"セ", @"se", @"ソ", @"so", 
      @"ザ", @"za", @"ジ", @"zi", @"ズ", @"zu", @"ゼ", @"ze", @"ゾ", @"zo",
      @"シャ", @"sya", @"シィ", @"syi", @"シュ", @"syu", @"シェ", @"sye", @"ショ", @"syo",
      @"スァ", @"swa", @"スィ", @"swi", @"スゥ", @"swu", @"スェ", @"swe", @"スォ", @"swo",
      @"ジャ", @"zya", @"ジィ", @"zyi", @"ジュ", @"zyu", @"ジェ", @"zye", @"ジョ", @"zyo",
      /* タ 행 */
      @"タ", @"ta", @"チ", @"ti", @"ツ", @"tu", @"テ", @"te", @"ト", @"to",
      @"ッ", @"xtu",
      @"ダ", @"da", @"ヂ", @"di", @"ヅ", @"du", @"デ", @"de", @"ド", @"do",
      @"チャ", @"tya", @"チィ", @"tyi", @"チュ", @"tyu", @"チェ", @"tye", @"チョ", @"tyo",
      @"ツァ", @"tsa", @"ツィ", @"tsi", @"ツェ", @"tse", @"ツォ", @"tso",
      @"テャ", @"tha", @"ティ", @"thi", @"テュ", @"thu", @"テェ", @"the", @"テョ", @"tho",
      @"トァ", @"twa", @"トィ", @"twi", @"トゥ", @"twu", @"トェ", @"twe", @"トォ", @"two",
      @"ヂャ", @"dya", @"ヂィ", @"dyi", @"ヂュ", @"dyu", @"ヂェ", @"dye", @"ヂョ", @"dyo",
      @"デャ", @"dha", @"ディ", @"dhi", @"デュ", @"dhu", @"デェ", @"dhe", @"デョ", @"dho",
      @"ドァ", @"dwa", @"ドィ", @"dwi", @"ドゥ", @"dwu", @"ドェ", @"dwe", @"ドォ", @"dwo",
      /* ナ 행 */
      @"ナ", @"na", @"ニ", @"ni", @"ヌ", @"nu", @"ネ", @"ne", @"ノ", @"no",
      @"ニャ", @"nya", @"ニィ", @"nyi", @"ニィ", @"nyu", @"ニェ", @"nye", @"ニョ", @"nyo",
      /* ハ 행 */
      @"ハ", @"ha", @"ヒ", @"hi", @"フ", @"hu", @"ヘ", @"he", @"ホ", @"ho",
      @"バ", @"ba", @"ビ", @"bi", @"ブ", @"bu", @"ベ", @"be", @"ボ", @"bo",
      @"パ", @"pa", @"ピ", @"pi", @"プ", @"pu", @"ペ", @"pe", @"ポ", @"po",
      @"ヒャ", @"hya", @"ヒィ", @"hyi", @"ヒュ", @"hyu", @"ヒェ", @"hye", @"ヒョ", @"hyo",
      @"フャ", @"fya", @"フュ", @"fyu", @"フョ", @"fyo",
      @"ビャ", @"bya", @"ビィ", @"byi", @"ビュ", @"byu", @"ビェ", @"bye", @"ビョ", @"byo",
      @"ヴァ", @"va", @"ヴィ", @"vi", @"ヴ", @"vu", @"ヴェ", @"ve", @"ヴォ", @"vo",
      @"ヴャ", @"vya", @"ヴィ", @"vyi", @"ヴュ", @"vyu", @"ヴェ", @"vye", @"ヴョ", @"vyo",
      @"ピャ", @"pya", @"ピィ", @"pyi", @"ピュ", @"pyu", @"ピェ", @"pye", @"ピョ", @"pyo",
      /* マ 행 */
      @"マ", @"ma", @"ミ", @"mi", @"ム", @"mu", @"メ", @"me", @"モ", @"mo",
      @"ミャ", @"mya", @"ミィ", @"myi", @"ミュ", @"myu", @"ミェ", @"mye", @"ミョ", @"myo",
      /* や 행 */
      @"ヤ", @"ya", @"ユ", @"yu", @"ヨ", @"yo",
      @"ャ", @"xya", @"ュ", @"xyu", @"ョ", @"xyo",
      /* ラ 행 */
      @"ラ", @"ra", @"リ", @"ri", @"ル", @"ru", @"レ", @"re", @"ロ", @"ro",
      @"リャ", @"rya", @"リィ", @"ryi", @"リュ", @"ryu", @"リェ", @"rye", @"リョ", @"ryo",
      /* ワ 행 */
      @"ワ", @"wa", @"ヲ", @"wo", 
      @"ヮ", @"xwa", @"ン", @"nn", nil];
}

- (NSDictionary *)synonymTable
{
  return nil;
}

- (NSString *)kanaForKey:(NSString *)key
		    mode:(NSString *)mode
{
  NSString *hepburn = [[self hepburnTable] objectForKey:key];

  if ([hepburn length] <= 0) {
    //NSLog(@"JapaneseEngine can not found Hepburn anontation for %@", key);
    return nil;
  } 
  
  if ([hepburn isEqual:@"="] || [hepburn isEqual:@"-"]) 
    return hepburn;

  NSString *ret;

  if ([mode isEqual:kBIMHiraganaMode]) {
    ret = [[self hiraganaTable] objectForKey:hepburn];
  } else {
    ret = [[self katakanaTable] objectForKey:hepburn];
  }

  return ret;
}

- (NSString *)kanaForHangul:(NSString *)hangul
		       mode:(NSString *)mode
{
  ucschar *utf32;
  ucschar initial, medial, final, combi;
  NSString *ret = nil;

  ret = [self kanaForKey:hangul mode:mode];

  //NSLog(@"kana:%@ hangul:%@", ret, hangul);

  if ([ret length] > 0) 
    return ret;

  // table not found
  if ([hangul length] > 1) {
    if ([hangul hasPrefix:@"-"] || [hangul hasPrefix:@"="]) 
      utf32 = (ucschar*)[[hangul substringFromIndex:1] cStringUsingEncoding:UTF32Encoding];
    else 
      return nil;
  } else
    utf32 = (ucschar*)[hangul cStringUsingEncoding:UTF32Encoding];
  
  hangul_syllable_to_jamo(*utf32, &initial, &medial, &final);

  combi = hangul_jamo_to_syllable(initial, medial, 0);
  final = hangul_jamo_to_cjamo(hangul_jongseong_to_choseong(final));

  NSString *first = [[NSString alloc]
		      initWithBytes:&combi
		      length:sizeof(ucschar)
		      encoding:UTF32Encoding];
  NSString *second = [[NSString alloc]
		       initWithBytes:&final
		       length:sizeof(ucschar)
		       encoding:UTF32Encoding];

  NSString *firstKana = [self kanaForKey:first mode:mode];
  NSString *secondKana = [self kanaForKey:second mode:mode];

  [first release];
  [second release];

  if ([firstKana length] > 0) {
    if ([secondKana length] > 0) {
      return [NSString stringWithFormat:@"%@%@", firstKana, secondKana, nil];
    } else {
      return [NSString stringWithString:firstKana];
    }
  } 

  return nil;
}

- (NSString*)translate:(NSString *)hangul
		toKana:(NSString *)mode
		 range:(NSRange)range
{
  NSUInteger i;
  NSMutableString *buf = [NSMutableString string];
    
  for (i=range.location; i<[hangul length]; i++) {
    NSString *currTwoSyllable;
    NSString *currOneSyllable;
    NSString *kana;

    if (i+2 <= [hangul length]) {
      currTwoSyllable = [hangul substringWithRange:NSMakeRange(i,2)];
      kana = [self kanaForHangul:currTwoSyllable mode:mode];

      if ([kana length] > 0) {
	[buf appendString:kana];
	i++;

	continue;
      } 
    }

    currOneSyllable = [hangul substringWithRange:NSMakeRange(i,1)];
    kana = [self kanaForHangul:currOneSyllable mode:mode];
      
    if ([kana length] > 0) 
      [buf appendString:kana];
    else 
      [buf appendString:currOneSyllable];
  }

  return buf;
}

- (NSArray *)kanaKanjiConversion:(NSString *)kana
{
	return nil;
}

@end
