#import <CoreText/CoreText.h>
#import "IOCTestHelper.h"
#import "NSAttributedString+GHFMarkdownTests.h"
#import "NSAttributedString+GHFMarkdown.h"


@implementation NSAttributedString_GHFMarkdownTests

- (void)testAttributedStringFromMarkdownWithBold {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold."];
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(5, 2)];
    expect([NSAttributedString attributedStringFromMarkdown:@"This **is** bold."]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithBoldAtStringBounds {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold"];
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(0, 4)];
    [expected addAttributes:attributes range:NSMakeRange(8, 4)];
    expect([NSAttributedString attributedStringFromMarkdown:@"__This__ is __bold__"]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithItalic {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is italic."];
    UIFont *font = [UIFont italicSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(5, 2)];
    expect([NSAttributedString attributedStringFromMarkdown:@"This *is* italic."]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithItalicAtStringBounds {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is italic"];
    UIFont *font = [UIFont italicSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(0, 4)];
    [expected addAttributes:attributes range:NSMakeRange(8, 6)];
    expect([NSAttributedString attributedStringFromMarkdown:@"_This_ is _italic_"]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeInline {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is code."];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:15], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    [expected addAttributes:attributes range:NSMakeRange(5, 2)];
    expect([NSAttributedString attributedStringFromMarkdown:@"This `is` code."]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeInlineAtStringBounds {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is code inline"];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:15], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    [expected addAttributes:attributes range:NSMakeRange(0, 4)];
    [expected addAttributes:attributes range:NSMakeRange(8, 11)];
    expect([NSAttributedString attributedStringFromMarkdown:@"`This` is `code inline`"]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeBlock {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This has\n\nruby\nputs 'Test'\n\n\na code block."];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:15], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    [expected addAttributes:attributes range:NSMakeRange(10, 17)];
    expect([NSAttributedString attributedStringFromMarkdown:@"This has\n\n```ruby\nputs 'Test'\n```\n\na code block."]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeBlocksAtStringBounds {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"ruby\nputs 'Test'\n\n\na code block\n\njavascript\nalert('Test');\n"];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:15], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    [expected addAttributes:attributes range:NSMakeRange(0, 17)];
    [expected addAttributes:attributes range:NSMakeRange(33, 26)];
    expect([NSAttributedString attributedStringFromMarkdown:@"```ruby\nputs 'Test'\n```\n\na code block\n\n```javascript\nalert('Test');\n```"]).to.equal(expected);
}

@end