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

- (void)testAttributedStringFromMarkdownWithHeadlines {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"Headline\n\nThis is text.\n\nSecond Headline\n\nMore text.\n\nThird Headline\n\nLast paragraph."];
    CGFloat baseSize = 15;
    CGFloat h1Size = 20;
    CGFloat h2Size = 19;
    CGFloat h3Size = 18;
    UIFont *font = [UIFont boldSystemFontOfSize:baseSize];
    CTFontRef h1Ref = CTFontCreateWithName((__bridge CFStringRef)font.fontName, h1Size, NULL);
    CTFontRef h2Ref = CTFontCreateWithName((__bridge CFStringRef)font.fontName, h2Size, NULL);
    CTFontRef h3Ref = CTFontCreateWithName((__bridge CFStringRef)font.fontName, h3Size, NULL);
    NSDictionary *h1Attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(h1Ref) forKey:(NSString *)kCTFontAttributeName];
    NSDictionary *h2Attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(h2Ref) forKey:(NSString *)kCTFontAttributeName];
    NSDictionary *h3Attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(h3Ref) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:h1Attributes range:NSMakeRange(0, 8)];
    [expected addAttributes:h2Attributes range:NSMakeRange(25, 15)];
    [expected addAttributes:h3Attributes range:NSMakeRange(54, 14)];
    expect([NSAttributedString attributedStringFromMarkdown:@"# Headline\n\nThis is text.\n\n## Second Headline ##\n\nMore text.\n\n### Third Headline\n\nLast paragraph."]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithBold {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold."];
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(5, 2)];
    expect([NSAttributedString attributedStringFromMarkdown:@"This **is** bold."]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithBoldAtStringBounds {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold"];
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(0, 4)];
    [expected addAttributes:attributes range:NSMakeRange(8, 4)];
    expect([NSAttributedString attributedStringFromMarkdown:@"__This__ is __bold__"]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithItalic {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is italic."];
    UIFont *font = [UIFont italicSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(5, 2)];
    expect([NSAttributedString attributedStringFromMarkdown:@"This *is* italic."]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithItalicAtStringBounds {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is italic"];
    UIFont *font = [UIFont italicSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(0, 4)];
    [expected addAttributes:attributes range:NSMakeRange(8, 6)];
    expect([NSAttributedString attributedStringFromMarkdown:@"_This_ is _italic_"]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithItalicAndNormalUnderscores {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is italic"];
    UIFont *font = [UIFont italicSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(0, 4)];
    [expected addAttributes:attributes range:NSMakeRange(8, 6)];
    expect([NSAttributedString attributedStringFromMarkdown:@"_This_ is _italic_"]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithUnderscoreWhichIsNotItalic {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is a file_name.rb get_it? But here is an italic part okay?"];
    UIFont *font = [UIFont italicSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(46, 11)];
    expect([NSAttributedString attributedStringFromMarkdown:@"This is a file_name.rb get_it? But here is an _italic part_ okay?"]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithBoldItalic {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold italic."];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:15];
    CTFontRef boldFontRef = CTFontCreateWithName((__bridge CFStringRef)boldFont.fontName, boldFont.pointSize, NULL);
    CTFontRef boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(boldFontRef, boldFont.pointSize, NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(boldItalicFontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(5, 2)];
    CFRelease(boldFontRef);
    expect([NSAttributedString attributedStringFromMarkdown:@"This ***is*** bold italic."]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithBoldItalicAtStringBounds {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold italic"];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:15];
    CTFontRef boldFontRef = CTFontCreateWithName((__bridge CFStringRef)boldFont.fontName, boldFont.pointSize, NULL);
    CTFontRef boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(boldFontRef, boldFont.pointSize, NULL, kCTFontItalicTrait, kCTFontItalicTrait);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:CFBridgingRelease(boldItalicFontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(0, 4)];
    [expected addAttributes:attributes range:NSMakeRange(8, 11)];
    CFRelease(boldFontRef);
    expect([NSAttributedString attributedStringFromMarkdown:@"___This___ is ___bold italic___"]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithList {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is\n* a normal list\n* with two entries\nThat's it."];
    expect([NSAttributedString attributedStringFromMarkdown:@"This is\n* a normal list\n* with two entries\nThat's it."]).to.equal(expected);
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

- (void)testAttributedStringFromMarkdownWithTasksAndLinks {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This has\n\n☑ A task with a link\n◻ List\nwithin plus an image"];
    NSAttributedString *actual = [NSAttributedString attributedStringFromMarkdown:@"This has\n\n- [x] A task with [a link](http://ioctocat.com)\n- [ ] List\nwithin plus ![an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png)"];
    expect(actual).to.equal(expected);
}

@end