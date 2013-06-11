#import <CoreText/CoreText.h>
#import "IOCTestHelper.h"
#import "NSMutableString+GHFMarkdownTests.h"
#import "NSMutableString+GHFMarkdown.h"


@implementation NSMutableString_GHFMarkdownTests

- (void)testSubstituteGHFMarkdownLinks {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This [is a link](http://ioctocat.com)."];
    [actual substituteGHFMarkdownLinks];
    expect(actual).to.equal(@"This is a link.");
}

- (void)testSubstituteGHFMarkdownImages {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This ![is an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png)."];
    [actual substituteGHFMarkdownImages];
    expect(actual).to.equal(@"This is an image.");
}

- (void)testSubstituteGHFMarkdownWithImageLink {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This [![is an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png)](http://ioctocat.com)."];
    [actual substituteGHFMarkdown];
    expect(actual).to.equal(@"This is an image.");
}

- (void)testSubstituteGHFMarkdownTasks {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This has\n\n- [x] A task\n- [ ] List\nwithin."];
    [actual substituteGHFMarkdownTasks];
    expect(actual).to.equal(@"This has\n\n☑ A task\n◻ List\nwithin.");
}

- (void)testSubstituteGHFMarkdownTasksAndLinks {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This has\n\n- [x] A task with [a link](http://ioctocat.com)\n- [ ] List\nwithin plus ![an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png)"];
    [actual substituteGHFMarkdownTasks];
    [actual substituteGHFMarkdownImages];
    [actual substituteGHFMarkdownLinks];
    expect(actual).to.equal(@"This has\n\n☑ A task with a link\n◻ List\nwithin plus an image");
}

- (void)testSubstituteGHFMarkdownHeadlines {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"# This has a headline\n\nAnd text\n\n## And a subline ##\nAnd more text."];
    [actual substituteGHFMarkdownHeadlines];
    expect(actual).to.equal(@"This has a headline\n\nAnd text\n\nAnd a subline\nAnd more text.");
}

- (void)testSubstitutePatternAndAddAttributesWithSourroundingMatch {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This **is** bold."];
    NSMutableString *expected = [[NSMutableString alloc] initWithString:@"This is bold."];
    [actual substitutePattern:@"(?:^|\\s)([*_]{2}(.+?)[*_]{2})(?:$|\\s)" options:(NSRegularExpressionCaseInsensitive)];
    expect(actual).to.equal(expected);
}

- (void)testSubstitutePatternAndAddAttributesWithoutSourroundingMatch {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This **is** bold."];
    NSMutableString *expected = [[NSMutableString alloc] initWithString:@"Thisisbold."];
    [actual substitutePattern:@"(?:^|\\s)[*_]{2}(.+?)[*_]{2}(?:$|\\s)" options:(NSRegularExpressionCaseInsensitive)];
    expect(actual).to.equal(expected);
}

@end