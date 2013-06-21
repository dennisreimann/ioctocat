#import <CoreText/CoreText.h>
#import "IOCTestHelper.h"
#import "NSMutableString_GHFMarkdownTests.h"
#import "GHFMarkdown.h"
#import "GHFMarkdown_Private.h"


@implementation NSMutableString_GHFMarkdownTests

- (void)testghf_substituteGHFMarkdownLinks {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This [is a link](http://ioctocat.com)."];
    [actual ghf_substituteGHFMarkdownLinks];
    expect(actual).to.equal(@"This is a link.");
}

- (void)testghf_substituteGHFMarkdownLinksWithImage {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This ![is an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png) and ![another one](http://upload.wikimedia.org/wikipedia/commons/thumb/b/be/SV-Werder-Bremen-Logo.svg/150px-SV-Werder-Bremen-Logo.svg.png \"Werder Bremen\")"];
    [actual ghf_substituteGHFMarkdownLinks];
    expect(actual).to.equal(@"This is an image and another one");
}

- (void)testghf_substituteGHFMarkdownWithImageLink {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This [![is an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png)](http://ioctocat.com)."];
    [actual ghf_substituteGHFMarkdown];
    expect(actual).to.equal(@"This is an image.");
}

- (void)testghf_substituteGHFMarkdownTasks {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This has\n\n- [x] A task\n- [ ] List\nwithin."];
    [actual ghf_substituteGHFMarkdownTasks];
    expect(actual).to.equal(@"This has\n\n[x] A task\n[ ] List\nwithin.");
}

- (void)testghf_substituteGHFMarkdownTasksAndLinks {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This has\n\n- [x] A task with [a link](http://ioctocat.com)\n- [ ] List\nwithin plus ![an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png)"];
    [actual ghf_substituteGHFMarkdownTasks];
    [actual ghf_substituteGHFMarkdownLinks];
    expect(actual).to.equal(@"This has\n\n[x] A task with a link\n[ ] List\nwithin plus an image");
}

- (void)testghf_substituteGHFMarkdownHeadlines {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"# This has a headline\n\nAnd text\n\n## And a subline ##\nAnd more text."];
    [actual ghf_substituteGHFMarkdownHeadlines];
    expect(actual).to.equal(@"This has a headline\n\nAnd text\n\nAnd a subline\nAnd more text.");
}

- (void)testghf_substituteGHFMarkdownQuotes {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This has\n\n> Quoted text\n\nas a block."];
    [actual ghf_substituteGHFMarkdownQuotes];
    expect(actual).to.equal(@"This has\n\n> Quoted text\n\nas a block.");
}

- (void)testghf_substituteGHFMarkdownQuotesWithMultilineQuote {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This has\n\n> Quoted text\n> And some more\n\nas a block."];
    [actual ghf_substituteGHFMarkdownQuotes];
    expect(actual).to.equal(@"This has\n\n> Quoted text\n> And some more\n\nas a block.");
}

- (void)testghf_substituteGHFMarkdownQuotesWithMultilineQuoteAndMissingLinebreaks {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This has\n> Quoted text\n> And some more\nas a block."];
    [actual ghf_substituteGHFMarkdownQuotes];
    expect(actual).to.equal(@"This has\n\n> Quoted text\n> And some more\n\nas a block.");
}

- (void)testghf_substituteGHFMarkdownQuotesAtStringBounds {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"> Quoted text\n\nNormal text\n> And some more"];
    [actual ghf_substituteGHFMarkdownQuotes];
    expect(actual).to.equal(@"> Quoted text\n\nNormal text\n\n> And some more");
}

- (void)testSubstitutePatternWithSourroundingMatch {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This **is** bold."];
    NSMutableString *expected = [[NSMutableString alloc] initWithString:@"This is bold."];
    [actual ghf_substitutePattern:@"(?:^|\\s)([*_]{2}(.+?)[*_]{2})(?:$|\\s)" options:(NSRegularExpressionCaseInsensitive)];
    expect(actual).to.equal(expected);
}

- (void)testSubstitutePatternWithoutSourroundingMatch {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This **is** bold."];
    NSMutableString *expected = [[NSMutableString alloc] initWithString:@"Thisisbold."];
    [actual ghf_substitutePattern:@"(?:^|\\s)[*_]{2}(.+?)[*_]{2}(?:$|\\s)" options:(NSRegularExpressionCaseInsensitive)];
    expect(actual).to.equal(expected);
}

@end