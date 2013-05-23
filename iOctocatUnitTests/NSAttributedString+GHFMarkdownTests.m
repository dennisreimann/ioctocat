#import <CoreText/CoreText.h>
#import "IOCTestHelper.h"
#import "NSAttributedString+GHFMarkdownTests.h"
#import "NSAttributedString+GHFMarkdown.h"


@interface NSAttributedString_GHFMarkdownTests ()
@property(nonatomic,strong)NSDictionary *codeAttributes;
@end


@implementation NSAttributedString_GHFMarkdownTests

- (void)setUp {
    [super setUp];
    self.codeAttributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:15], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
}

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

- (void)testAttributedStringFromMarkdownWithBoldItalic {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold italic."];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:15];
    CTFontRef boldFontRef = CTFontCreateWithName((__bridge CFStringRef)boldFont.fontName, boldFont.pointSize, NULL);
    CTFontRef boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(boldFontRef, boldFont.pointSize, NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(boldItalicFontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(5, 2)];
    expect([NSAttributedString attributedStringFromMarkdown:@"This ***is*** bold italic."]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithBoldItalicAtStringBounds {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold italic"];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:15];
    CTFontRef boldFontRef = CTFontCreateWithName((__bridge CFStringRef)boldFont.fontName, boldFont.pointSize, NULL);
    CTFontRef boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(boldFontRef, boldFont.pointSize, NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(boldItalicFontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(0, 4)];
    [expected addAttributes:attributes range:NSMakeRange(8, 11)];
    expect([NSAttributedString attributedStringFromMarkdown:@"___This___ is ___bold italic___"]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeInline {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is code."];
    [expected addAttributes:self.codeAttributes range:NSMakeRange(5, 2)];
    expect([NSAttributedString attributedStringFromMarkdown:@"This `is` code."]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeInlineAtStringBounds {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is code inline"];
    [expected addAttributes:self.codeAttributes range:NSMakeRange(0, 4)];
    [expected addAttributes:self.codeAttributes range:NSMakeRange(8, 11)];
    expect([NSAttributedString attributedStringFromMarkdown:@"`This` is `code inline`"]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeInlineAsCodeHtml {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is code"];
    [expected addAttributes:self.codeAttributes range:NSMakeRange(5, 2)];
    expect([NSAttributedString attributedStringFromMarkdown:@"This <code>is</code> code"]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeBlock {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This has\n\nruby\nputs 'Test'\n\n\na code block."];
    [expected addAttributes:self.codeAttributes range:NSMakeRange(10, 17)];
    expect([NSAttributedString attributedStringFromMarkdown:@"This has\n\n```ruby\nputs 'Test'\n```\n\na code block."]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeBlocksAtStringBounds {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"ruby\nputs 'Test'\n\n\na code block\n\njavascript\nalert('Test');\n"];
    [expected addAttributes:self.codeAttributes range:NSMakeRange(0, 17)];
    [expected addAttributes:self.codeAttributes range:NSMakeRange(33, 26)];
    expect([NSAttributedString attributedStringFromMarkdown:@"```ruby\nputs 'Test'\n```\n\na code block\n\n```javascript\nalert('Test');\n```"]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeBlockAsPreHtml {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This has\n\nputs 'Test'\n\na pre block."];
    [expected addAttributes:self.codeAttributes range:NSMakeRange(10, 11)];
    expect([NSAttributedString attributedStringFromMarkdown:@"This has\n\n<pre>puts 'Test'</pre>\n\na pre block."]).to.equal(expected);
}

@end