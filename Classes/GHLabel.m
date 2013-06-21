#import "GHLabel.h"
#import "GHRepository.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"


@implementation GHLabel

- (id)initWithRepository:(GHRepository *)repo name:(NSString *)name {
	self = [super init];
	if (self) {
        self.repository = repo;
        self.name = name;
        self.resourcePath = [NSString stringWithFormat:kLabelFormat, self.repository.owner, self.repository.name, self.name];
	}
	return self;
}

// TODO: Figure out how to distinguish this state
- (BOOL)isNew {
	return YES;
}

- (NSString *)resourcePath {
	if (self.isNew) {
		return [NSString stringWithFormat:kLabelsFormat, self.repository.owner, self.repository.name];
	} else {
        return [NSString stringWithFormat:kLabelFormat, self.repository.owner, self.repository.name, self.name];
	}
}

- (void)setHexColor:(NSString *)hexColor {
    _hexColor = hexColor;
    self.color = _hexColor ? [self colorWithHexString:_hexColor] : nil;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	self.name = [dict ioc_stringForKey:@"name"];
	self.hexColor = [dict ioc_stringForKey:@"color"];
}

#pragma mark Helpers

// taken from http://stackoverflow.com/a/6207457/183537
- (UIColor*)colorWithHexString:(NSString*)hex {
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString length] != 6) return  [UIColor grayColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

@end
