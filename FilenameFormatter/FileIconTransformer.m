#import "FileIconTransformer.h"

@implementation FileIconTransformer

+ (Class)transformedValueClass {
    return [NSImage class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:(NSString*)value];
	if (!icon)
		icon = [[NSWorkspace sharedWorkspace] iconForFileType:[(NSString*)value pathExtension]];
	
	return icon;
}

@end