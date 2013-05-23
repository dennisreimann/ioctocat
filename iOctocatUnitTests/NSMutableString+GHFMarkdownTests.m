#import <CoreText/CoreText.h>
#import "IOCTestHelper.h"
#import "NSMutableString+GHFMarkdownTests.h"
#import "NSMutableString+GHFMarkdown.h"


@implementation NSMutableString_GHFMarkdownTests

- (void)testSubstituteMarkdownLinks {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This [is a link](http://ioctocat.com)."];
    [actual substituteMarkdownLinks];
    expect(actual).to.equal(@"This is a link.");
}

- (void)testSubstituteMarkdownLinksWithImage {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This ![is an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png)."];
    [actual substituteMarkdownLinks];
    expect(actual).to.equal(@"This is an image.");
}

- (void)testSubstituteMarkdownTasks {
    NSMutableString *actual = [[NSMutableString alloc] initWithString:@"This has\n\n- [x] A task\n- [ ] List\nwithin."];
    [actual substituteMarkdownTasks];
    expect(actual).to.equal(@"This has\n\n☑ A task\n◻ List\nwithin.");
}

@end