#import <CoreText/CoreText.h>
#import "IOCTestHelper.h"
#import "NSMutableAttributedString_GHFMarkdownTests.h"
#import "GHFMarkdown.h"
#import "GHFMarkdown_Private.h"


@interface NSMutableAttributedString_GHFMarkdownTests ()
@property(nonatomic,strong)NSDictionary *quoteAttributes;
@property(nonatomic,strong)NSDictionary *codeAttributes;
@end


@implementation NSMutableAttributedString_GHFMarkdownTests

- (void)testSubstitutePatternWithSourroundingMatch {
    NSMutableAttributedString *actual = [[NSMutableAttributedString alloc] initWithString:@"This **is** bold."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold."];
    NSDictionary *attributes = @{@"BOLD": @YES};
    [expected addAttributes:attributes range:NSMakeRange(5, 2)];
    [actual ghf_substitutePattern:@"(?:^|\\s)([*_]{2}(.+?)[*_]{2})(?:$|\\s)" options:(NSRegularExpressionCaseInsensitive) addAttributes:attributes];
    expect(actual).to.equal(expected);
}

- (void)testSubstitutePatternWithoutSourroundingMatch {
    NSMutableAttributedString *actual = [[NSMutableAttributedString alloc] initWithString:@"This **is** bold."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"Thisisbold."];
    NSDictionary *attributes = @{@"BOLD": @YES};
    [expected addAttributes:attributes range:NSMakeRange(4, 2)];
    [actual ghf_substitutePattern:@"(?:^|\\s)[*_]{2}(.+?)[*_]{2}(?:$|\\s)" options:(NSRegularExpressionCaseInsensitive) addAttributes:attributes];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithHeadlines {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"# Headline\n\nThis is text.\n\n## Second Headline ##\n\nMore text.\n\n### Third Headline\n\nLast paragraph."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"Headline\n\nThis is text.\n\nSecond Headline\n\nMore text.\n\nThird Headline\n\nLast paragraph."];
    [expected addAttributes:@{@"GHFMarkdown_Headline": @1, @"GHFMarkdown_Headline1": @YES} range:NSMakeRange(0, 8)];
    [expected addAttributes:@{@"GHFMarkdown_Headline": @2, @"GHFMarkdown_Headline2": @YES} range:NSMakeRange(25, 15)];
    [expected addAttributes:@{@"GHFMarkdown_Headline": @3, @"GHFMarkdown_Headline3": @YES} range:NSMakeRange(54, 14)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithBold {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This **is** bold."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold."];
    [expected addAttributes:@{@"GHFMarkdown_Bold": @YES} range:NSMakeRange(5, 2)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithBoldAtStringBounds {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"__This__ is __bold__"];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold"];
    [expected addAttributes:@{@"GHFMarkdown_Bold": @YES} range:NSMakeRange(0, 4)];
    [expected addAttributes:@{@"GHFMarkdown_Bold": @YES} range:NSMakeRange(8, 4)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithItalic {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This *is* italic."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is italic."];
    [expected addAttributes:@{@"GHFMarkdown_Italic": @YES} range:NSMakeRange(5, 2)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithItalicAtStringBounds {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"_This_ is _italic_"];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is italic"];
    [expected addAttributes:@{@"GHFMarkdown_Italic": @YES} range:NSMakeRange(0, 4)];
    [expected addAttributes:@{@"GHFMarkdown_Italic": @YES} range:NSMakeRange(8, 6)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithUnderscoreWhichIsNotItalic {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This is a file_name.rb get_it? But here is an _italic part_ okay?"];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is a file_name.rb get_it? But here is an italic part okay?"];
    [expected addAttributes:@{@"GHFMarkdown_Italic": @YES} range:NSMakeRange(46, 11)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithBoldItalic {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This ***is*** bold italic."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold italic."];
    [expected addAttributes:@{@"GHFMarkdown_BoldItalic": @YES} range:NSMakeRange(5, 2)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithBoldItalicAtStringBounds {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"___This___ is ___bold italic___"];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold italic"];
    [expected addAttributes:@{@"GHFMarkdown_BoldItalic": @YES} range:NSMakeRange(0, 4)];
    [expected addAttributes:@{@"GHFMarkdown_BoldItalic": @YES} range:NSMakeRange(8, 11)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithList {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This is\n* a normal list\n* with two entries\nThat's it."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is\n* a normal list\n* with two entries\nThat's it."];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithCodeInline {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This `is` code."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is code."];
    [expected addAttributes:@{@"GHFMarkdown_CodeInline": @YES} range:NSMakeRange(5, 2)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithCodeInlineAtStringBounds {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"`This` is `code inline`"];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is code inline"];
    [expected addAttributes:@{@"GHFMarkdown_CodeInline": @YES} range:NSMakeRange(0, 4)];
    [expected addAttributes:@{@"GHFMarkdown_CodeInline": @YES} range:NSMakeRange(8, 11)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithCodeInlineAsCodeHtml {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This <code>is</code> code"];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is code"];
    [expected addAttributes:@{@"GHFMarkdown_CodeInline": @YES} range:NSMakeRange(5, 2)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithCodeBlock {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This has\n\n```ruby\nputs 'Test'\n```\n\na code block."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This has\n\nputs 'Test'\n\n\na code block."];
    [expected addAttributes:@{@"GHFMarkdown_CodeBlock": @YES} range:NSMakeRange(10, 12)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeBlocksAtStringBounds {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"```ruby\nputs 'Test'\n```\n\na code block\n\n```javascript\nalert('Test');\n```"];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"puts 'Test'\n\n\na code block\n\nalert('Test');\n"];
    [expected addAttributes:@{@"GHFMarkdown_CodeBlock": @YES} range:NSMakeRange(0, 12)];
    [expected addAttributes:@{@"GHFMarkdown_CodeBlock": @YES} range:NSMakeRange(28, 15)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithCodeBlockAsPreHtml {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This has\n\n<pre>puts 'Test'</pre>\n\na pre block."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This has\n\nputs 'Test'\n\na pre block."];
    [expected addAttributes:@{@"GHFMarkdown_CodeBlock": @YES} range:NSMakeRange(10, 11)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithCodeBlockAndContainingStuff {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This has\n\n```**bold** *italic* [leave this alone](http://link.com) test\n```\n\na code block."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This has\n\n**bold** *italic* [leave this alone](http://link.com) test\n\n\na code block."];
    [expected addAttributes:@{@"GHFMarkdown_CodeBlock": @YES} range:NSMakeRange(10, 59)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithTasksAndLinks {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This has\n\n- [x] A task with [a link](http://ioctocat.com)\n- [ ] List\nwithin plus ![an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png)"];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This has\n\n☑ A task with a link\n◻ List\nwithin plus an image"];
    [expected addAttributes:@{@"GHFMarkdown_Task": @YES} range:NSMakeRange(10, 20)];
    [expected addAttributes:@{@"GHFMarkdown_Link": [NSURL URLWithString:@"http://ioctocat.com"]} range:NSMakeRange(24, 6)];
    [expected addAttributes:@{@"GHFMarkdown_Task": @NO} range:NSMakeRange(31, 6)];
    [expected addAttributes:@{@"GHFMarkdown_Link": [NSURL URLWithString:@"http://ioctocat.com/img/iOctocat-GitHub_iOS.png"]} range:NSMakeRange(50, 8)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithQuote {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This has\n\n> Quoted text\n\nas a block."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This has\n\n> Quoted text\n\nas a block."];
    [expected addAttributes:@{@"GHFMarkdown_Quote": @YES} range:NSMakeRange(10, 13)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithMultilineQuote {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This has\n\n> Quoted text\n> And some more\n\nas a block."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This has\n\n> Quoted text\n> And some more\n\nas a block."];
    [expected addAttributes:@{@"GHFMarkdown_Quote": @YES} range:NSMakeRange(10, 29)];
    expect(actual).to.equal(expected);
}

- (void)testAttributedStringFromGHFMarkdownWithMultilineQuoteAndMissingLinebreaks {
    NSMutableAttributedString *actual = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:@"This has\n> Quoted text\n> And some more\nas a block."];
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This has\n\n> Quoted text\n> And some more\n\nas a block."];
    [expected addAttributes:@{@"GHFMarkdown_Quote": @YES} range:NSMakeRange(10, 29)];
    expect(actual).to.equal(expected);
}

@end