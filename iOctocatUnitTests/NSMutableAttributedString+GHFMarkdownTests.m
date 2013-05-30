#import <CoreText/CoreText.h>
#import "IOCTestHelper.h"
#import "NSMutableAttributedString+GHFMarkdownTests.h"
#import "NSMutableAttributedString+GHFMarkdown.h"


@implementation NSMutableAttributedString_GHFMarkdownTests

- (void)testSubstitutePatternAndAddAttributesWithSourroundingMatch {
    NSMutableAttributedString *actual = [[NSMutableAttributedString alloc] initWithString:@"This **is** bold."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold."];
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(5, 2)];
    [actual substitutePattern:@"(?:^|\\s)([*_]{2}(.+?)[*_]{2})(?:$|\\s)" andAddAttributes:attributes];
    expect(actual).to.equal(expected);
}

- (void)testSubstitutePatternAndAddAttributesWithoutSourroundingMatch {
    NSMutableAttributedString *actual = [[NSMutableAttributedString alloc] initWithString:@"This **is** bold."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"Thisisbold."];
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(4, 2)];
    [actual substitutePattern:@"(?:^|\\s)[*_]{2}(.+?)[*_]{2}(?:$|\\s)" andAddAttributes:attributes];
    expect(actual).to.equal(expected);
}

@end