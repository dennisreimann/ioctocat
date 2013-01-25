#import "FakeTestCase.h"

@implementation FakeTestCase

- (void)failWithException:(NSException *)exception {
  NSException *e = [NSException exceptionWithName:[exception reason] reason:[exception reason] userInfo:nil];
  [e raise];
}

@end
