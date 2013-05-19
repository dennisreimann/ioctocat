#import <CoreText/CoreText.h>
#import "IOCTestHelper.h"
#import "NSString+GHFMarkdownTests.h"
#import "NSString+GHFMarkdown.h"


@implementation NSString_GHFMarkdownTests

- (void)testAttributedStringFromMarkdownWithBold {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is bold."];
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
    [expected addAttributes:attributes range:NSMakeRange(5, 2)];
	expect([@"This **is** bold." attributedStringFromMarkdown]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithItalic {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is italic."];
    UIFont *font = [UIFont italicSystemFontOfSize:15];
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:(id)CFBridgingRelease(fontRef) forKey:(NSString *)kCTFontAttributeName];
	[expected addAttributes:attributes range:NSMakeRange(5, 2)];
	expect([@"This *is* italic." attributedStringFromMarkdown]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeInline {
    NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This is code."];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:15], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    [expected addAttributes:attributes range:NSMakeRange(5, 2)];
	expect([@"This `is` code." attributedStringFromMarkdown]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithCodeBlock {
	NSMutableAttributedString *expected = [[NSMutableAttributedString alloc] initWithString:@"This has\n\n ruby\nputs 'Test'\n\n\na code block."];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:15], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    [expected addAttributes:attributes range:NSMakeRange(10, 18)];
	expect([@"This has\n\n``` ruby\nputs 'Test'\n```\n\na code block." attributedStringFromMarkdown]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithTasks {
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"This has\n\n☑ A task\n☐ List\nwithin."];
	expect([@"This has\n\n- [x] A task\n- [ ] List\nwithin." attributedStringFromMarkdown]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithLink {
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"This is a link."];
	expect([@"This [is a link](http://ioctocat.com)." attributedStringFromMarkdown]).to.equal(expected);
}

- (void)testAttributedStringFromMarkdownWithImage {
    NSAttributedString *expected = [[NSAttributedString alloc] initWithString:@"This is an image."];
	expect([@"This ![is an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png)." attributedStringFromMarkdown]).to.equal(expected);
}

- (void)testGhfmarkdownLinks {
    NSString *string = @"This [is a link](http://ioctocat.com) and this ![an image](http://ioctocat.com/img/iOctocat-GitHub_iOS.png).";
    NSArray *links = [string markdownLinks];
    NSDictionary *link = links[0];
    NSDictionary *image = links[1];
	expect(links.count).to.equal(2);
	expect(link[@"title"]).to.equal(@"is a link");
	expect(link[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com"]);
	expect(image[@"title"]).to.equal(@"an image");
	expect(image[@"url"]).to.equal([NSURL URLWithString:@"http://ioctocat.com/img/iOctocat-GitHub_iOS.png"]);
}

@end