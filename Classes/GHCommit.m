#import "GHCommit.h"


@implementation GHCommit

@synthesize commitID, tree, message, commitURL, authorName, authorEmail, committerName, committerEmail, committedDate, authoredDate;

- (id)initWithCommitID:(NSString *)theCommitID {
	if (self = [super init]) {
		self.commitID = theCommitID;
	}
	return self;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[commitID release];
	[tree release];
	[message release];
	[commitURL release];
	[authorName release];
	[authorEmail release];
	[committerName release];
	[committerEmail release];
	[committedDate release];
	[authoredDate release];
	[super dealloc];
}

@end
