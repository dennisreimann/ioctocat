#import "GHBranch.h"
#import "GHRepository.h"
#import "GHFeed.h"
#import "NSURL+Extensions.h"


@implementation GHBranch

@synthesize repository;
@synthesize recentCommits;
@synthesize name;
@synthesize sha;

- (id)initWithRepository:(GHRepository *)theRepository andName:(NSString *)theName {
	[super init];
	self.repository = theRepository;
	self.name = theName;
	// Recent Commits
	NSURL *feedURL = [NSURL URLWithFormat:(repository.isPrivate ? kRepoPrivateFeedFormat : kRepoFeedFormat), repository.owner, repository.name, name];
	self.recentCommits = [GHFeed resourceWithURL:feedURL];
	return self;
}

- (void)dealloc {
	[repository release], repository = nil;
	[recentCommits release], recentCommits = nil;
	[name release], name = nil;
	[sha release], sha = nil;
	[super dealloc];
}

@end
