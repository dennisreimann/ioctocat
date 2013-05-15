#import "IOCTestHelper.h"
#import "NSString+GHFMarkdownTests.h"
#import "NSString+GHFMarkdown.h"


@implementation NSString_GHFMarkdownTests

- (void)testAttributedStringFromMarkdownWithLink {
	expect([@"This [is a link](http://ioctocat.com)." attributedStringFromMarkdown]).to.equal([[NSAttributedString alloc] initWithString:@"This is a link."]);
}

- (void)testGhfmarkdownLinks {
    NSString *string = @"This [is a link](http://ioctocat.com).";
    NSArray *links = [string markdownLinks];
    
	expect(links.count).to.equal(1);
    
    NSDictionary *link = links[0];
    
	expect(link[@"title"]).to.equal(@"is a link");
	expect(link[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com"]);
}

@end