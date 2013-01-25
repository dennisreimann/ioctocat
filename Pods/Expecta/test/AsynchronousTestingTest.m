#import "TestHelper.h"

@interface AsynchronousTestingTest : SenTestCase
@end

@implementation AsynchronousTestingTest

- (void)performBlock:(void(^)())block {
  block();
}

- (void)test_isGoing {
  __block NSString *foo = @"";
  [self performSelector:@selector(performBlock:) withObject:[[^{
    foo = @"foo";
  } copy] autorelease] afterDelay:0.1];
  assertPass(test_expect(foo).will.equal(@"foo"));
  assertFail(test_expect(foo).will.equal(@"bar"), @"expected: bar, got: foo");
}

- (void)test_isNotGoing {
  __block NSString *foo = @"bar";
  [self performSelector:@selector(performBlock:) withObject:[[^{
    foo = @"foo";
  } copy] autorelease] afterDelay:0.1];
  assertPass(test_expect(foo).willNot.equal(@"bar"));
  assertFail(test_expect(foo).willNot.equal(@"foo"), @"expected: not foo, got: foo");
}

- (void)test_Expecta_setAsynchronousTestTimeout {
  assertEquals([Expecta asynchronousTestTimeout], 1.0);
  [Expecta setAsynchronousTestTimeout: 10.0];
  assertEquals([Expecta asynchronousTestTimeout], 10.0);
  [Expecta setAsynchronousTestTimeout: 1.0];
  assertEquals([Expecta asynchronousTestTimeout], 1.0);
}

@end
