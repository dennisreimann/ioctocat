#import "NSURL+Extensions.h"


@implementation NSURL (Extensions)

+ (NSURL *)URLWithFormat:(NSString *)formatString, ... {
	va_list args;
    va_start(args, formatString);
    NSString *urlString = [[[NSString alloc] initWithFormat:formatString arguments:args] autorelease];
    va_end(args);
	return [NSURL URLWithString:urlString];
}

@end
