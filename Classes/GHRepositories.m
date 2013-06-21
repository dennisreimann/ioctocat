#import "GHRepositories.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSDictionary_IOCExtensions.h"


@implementation GHRepositories

- (void)setValues:(id)values {
    [super setValues:values];
	for (NSDictionary *dict in values) {
		NSString *owner = [dict ioc_stringForKeyPath:@"owner.login"];
		NSString *name = [dict ioc_stringForKey:@"name"];
		GHRepository *repo = [[GHRepository alloc] initWithOwner:owner andName:name];
		[repo setValues:dict];
		[self addObject:repo];
	}
}

- (void)sortByPushedAt {
	NSComparisonResult (^compareRepositories)(GHRepository *, GHRepository *);
	compareRepositories = ^(GHRepository *repo1, GHRepository *repo2) {
		if (!repo1.pushedAtDate) return NSOrderedDescending;
		if (!repo2.pushedAtDate) return NSOrderedAscending;
		return (NSInteger)[repo2.pushedAtDate compare:repo1.pushedAtDate];
	};
	[self.items sortUsingComparator:compareRepositories];
}

@end