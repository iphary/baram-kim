#if defined(TARGET_CPU_X86) || defined(TARGET_CPU_X86_64)
#define UTF32Encoding NSUTF32LittleEndianStringEncoding
#define UTF32toNSString(string) (NSString *)CFStringCreateWithBytes(kCFAllocatorDefault, (const UInt8 *)string, wcslen(string)*sizeof(ucschar), kCFStringEncodingUTF32LE, false)
#else 
#define UTF32Encoding NSUTF32BigEndianStringEncoding
#define UTF32toNSString(string) (NSString *)CFStringCreateWithBytes(kCFAllocatorDefault, (const UInt8 *)string, wcslen(string)*sizeof(ucschar), kCFStringEncodingUTF32BE, false)
#endif
