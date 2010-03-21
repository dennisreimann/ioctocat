#import "NSString+Extensions.h"


@implementation NSString (Extensions)

- (NSString *)lowercaseFirstCharacter {
	NSRange range = NSMakeRange(0,1);
	NSString *lowerFirstCharacter = [[self substringToIndex:1] lowercaseString];
	return [self stringByReplacingCharactersInRange:range withString:lowerFirstCharacter];
}

- (BOOL)isEmpty {
	NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *trimmed = [self stringByTrimmingCharactersInSet:charSet];
	return [trimmed isEqualToString:@""];
}

@end
