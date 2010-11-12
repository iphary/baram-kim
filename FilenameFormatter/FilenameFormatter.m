#import "FilenameFormatter.h"

@implementation FilenameFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
	NSString *displayName = [[NSFileManager defaultManager] displayNameAtPath:anObject];
	
	if ([displayName length] > 0)
		return displayName;
	else
		return [anObject lastPathComponent];
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
	NSString *displayName = [[NSFileManager defaultManager] displayNameAtPath:string];
	
	if ([displayName length] > 0)
		*anObject = displayName;
	else
		*anObject = [string lastPathComponent];
		
	return YES;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes
{
	NSString *displayName = [[NSFileManager defaultManager] displayNameAtPath:anObject];
	
	if ([displayName length] > 0)
		return [[NSAttributedString alloc] initWithString:displayName attributes:attributes];
	else
		return [[NSAttributedString alloc] initWithString:[anObject lastPathComponent] attributes:attributes];
}

@end