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

- (NSString *)escapeHTML {
    NSMutableString *result = [[NSMutableString alloc] initWithString:self];
    [result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"'" withString:@"&#39;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    return [result autorelease];
}

@end
