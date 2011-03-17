#import "GHBranch.h"
#import "GHRepository.h"
#import "GHFeed.h"


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
	NSString *urlString = [NSString stringWithFormat:(repository.isPrivate ? kRepoPrivateFeedFormat : kRepoFeedFormat), repository.owner, repository.name, name];
	NSURL *feedURL = [NSURL URLWithString:urlString];
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
