#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"


@implementation NSURL (Extensions)

+ (NSURL *)URLWithFormat:(NSString *)formatString, ... {
	va_list args;
	va_start(args, formatString);
	NSString *urlString = [[NSString alloc] initWithFormat:formatString arguments:args];
	va_end(args);
	return [NSURL URLWithString:urlString];
}

+ (NSURL *)smartURLFromString:(NSString *)string {
	if (!string || [string isKindOfClass:[NSNull class]] || [string isEmpty]) {
		return nil;
	} else {
		NSURL *url = [NSURL URLWithString:string];
		if ([url scheme]) {
			return url;
		} else {
			string = [@"http://" stringByAppendingString:string];
			return [NSURL URLWithString:string];
		}
	}
}

// Taken from https://gist.github.com/1256354
- (NSURL *)URLByAppendingParams:(NSDictionary *)params {
	NSMutableString *query = [[self query] mutableCopy];

	if (!query) {
		query = [NSMutableString stringWithString:@""];
	}

	// Sort parameters to be appended so that our solution is stable (and testable)
	NSArray *parameterNames = [params allKeys];
	parameterNames = [parameterNames sortedArrayUsingSelector:@selector(compare:)];

	for (NSString *parameterName in parameterNames) {
		id value = params[parameterName];
		NSAssert3([parameterName isKindOfClass:[NSString class]], @"Got '%@' of type %@ as key for parameter with value '%@'. Expected an NSString.", parameterName, NSStringFromClass([parameterName class]), value);

		// The value needs to be an NSString, or be able to give us an NSString
		if (![value isKindOfClass:[NSString class]]) {
			if ([value respondsToSelector:@selector(stringValue)]) {
				value = [value stringValue];
			} else {
				// Fallback to simply giving the description
				value = [value description];
			}
		}

		if ([query length] == 0) {
			[query appendFormat:@"%@=%@", [parameterName stringByEscapingForURLArgument], [value stringByEscapingForURLArgument]];
		} else {
			[query appendFormat:@"&%@=%@", [parameterName stringByEscapingForURLArgument], [value stringByEscapingForURLArgument]];
		}
	}

	// scheme://username:password@domain:port/path?query_string#fragment_id

	// Chop off query and fragment from absoluteString, then add new query and put back fragment

	NSString *absoluteString = [self absoluteString];
	NSUInteger endIndex = [absoluteString length];

	NSString *fragment = [self fragment];
	if (fragment) {
		endIndex -= [fragment length];
		endIndex--; // The # character
	}

	NSString *originalQuery = [self query];
	if (originalQuery) {
		endIndex -= [originalQuery length];
		endIndex--; // The ? character
	}

	absoluteString = [absoluteString substringToIndex:endIndex];
	absoluteString = [absoluteString stringByAppendingString:@"?"];
	absoluteString = [absoluteString stringByAppendingString:query];
	if (fragment) {
		absoluteString = [absoluteString stringByAppendingString:@"#"];
		absoluteString = [absoluteString stringByAppendingString:fragment];
	}

	return [NSURL URLWithString:absoluteString];
}

@end