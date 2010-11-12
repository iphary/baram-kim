#import <Cocoa/Cocoa.h>

@interface FilenameFormatter : NSFormatter {

}

- (NSString *)stringForObjectValue:(id)anObject;
- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error;
- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes;

@end