#import "TestHelper.h"
#import "ExpectaSupport.h"

@interface MiscTest : SenTestCase
@end

@implementation MiscTest

- (void)test_StrippingOfLineBreaksInObjectDescription {
  NSArray *arr = [NSArray arrayWithObjects:@"foo", @"bar", nil];
  NSSet *set = [NSSet setWithObjects:@"foo", @"bar", nil];
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo", nil];
  expect(EXPDescribeObject(@"\n")).toNot.contain(@"\n");
  expect(EXPDescribeObject(@"\n")).equal(@"\\n");
  expect(EXPDescribeObject(arr)).toNot.contain(@"\n");
  expect(EXPDescribeObject(arr)).equal(@"(foo, bar)");
  expect(EXPDescribeObject(set)).toNot.contain(@"\n");
  expect(EXPDescribeObject(set)).equal(@"{(foo, bar)}");
  expect(EXPDescribeObject(dict)).toNot.contain(@"\n");
  expect(EXPDescribeObject(dict)).equal(@"{foo = bar;}");
}

@end
