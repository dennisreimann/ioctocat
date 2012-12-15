#import "IOCTestHelper.h"

@implementation IOCTestHelper

// loads test fixture from json file
// http://blog.roberthoglund.com/2010/12/ios-unit-testing-loading-bundle.html
+ (id)jsonFixture:(NSString *)fixture {
	NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:fixture ofType:@"json"];
	NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:path];
	return [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
}

@end
