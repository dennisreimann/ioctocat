#import "IOCUtilTests.h"
#import "IOCUtil.h"


@implementation IOCUtilTests

- (void)testHighlightLanguageForFilename {
	expect([IOCUtil highlightLanguageForFilename:@"test.md"]).to.equal(@"markdown");
	expect([IOCUtil highlightLanguageForFilename:@"test.markdown"]).to.equal(@"markdown");
	expect([IOCUtil highlightLanguageForFilename:@"Gemfile"]).to.equal(@"ruby");
	expect([IOCUtil highlightLanguageForFilename:@"Rakefile"]).to.equal(@"ruby");
	expect([IOCUtil highlightLanguageForFilename:@"TestClass.h"]).to.equal(@"objective-c");
	expect([IOCUtil highlightLanguageForFilename:@"TestClass.m"]).to.equal(@"objective-c");
	expect([IOCUtil highlightLanguageForFilename:@"config.ru"]).to.equal(@"ruby");
	expect([IOCUtil highlightLanguageForFilename:@"tasks.rake"]).to.equal(@"ruby");
	expect([IOCUtil highlightLanguageForFilename:@"config.yml"]).to.equal(@"yaml");
	expect([IOCUtil highlightLanguageForFilename:@"Gemfile.lock"]).to.equal(@"no-highlight");
	expect([IOCUtil highlightLanguageForFilename:@"hello.txt"]).to.equal(@"no-highlight");
}

@end