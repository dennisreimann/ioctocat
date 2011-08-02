#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"


@implementation NSURL (Extensions)

+ (NSURL *)URLWithFormat:(NSString *)formatString, ... {
	va_list args;
    va_start(args, formatString);
    NSString *urlString = [[[NSString alloc] initWithFormat:formatString arguments:args] autorelease];
    va_end(args);
	return [NSURL URLWithString:urlString];
}

+ (NSURL *)smartURLFromString:(NSString *)theString {
    if (!theString || [theString isKindOfClass:[NSNull class]] || [theString isEmpty]) {
        return nil;
    } else {
        NSURL *url = [NSURL URLWithString:theString];
        if ([url scheme]) {
            return url;
        } else {
            theString = [@"http://" stringByAppendingString:theString];
            return [NSURL URLWithString:theString];
        }
    }
}

@end
