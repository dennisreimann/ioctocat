#import "GHApplication.h"
#import "iOctocat.h"


@implementation GHApplication

- (BOOL)openURL:(NSURL *)url {
	return [(iOctocat *)self.delegate openURL:url] ? YES : [super openURL:url];
}

@end