#import "AppConstants.h"
#import "GHRepository.h"
#import "GHUser.h"


@interface GHRepository (PrivateMethods)

@end


@implementation GHRepository

@synthesize user, name, owner, descriptionText, githubURL, homepageURL, isPrivate, isFork, forks, watchers;

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHRepository name:'%@' owner:'%@' descriptionText:'%@' githubURL:'%@' homepageURL:'%@' isPrivate:'%@' isFork:'%@' forks:'%d' watchers:'%d'>", name, owner, descriptionText, githubURL, homepageURL, isPrivate ? @"YES" : @"NO", isFork ? @"YES" : @"NO", forks, watchers];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[user release];
	[name release];
	[owner release];
	[descriptionText release];
	[githubURL release];
	[homepageURL release];
    [super dealloc];
}

@end
