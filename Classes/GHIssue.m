#import "GHIssue.h"


@implementation GHIssue

@synthesize issueId, user, title, body, state, type, votes, created, updated, num, repo;    

- (id)initWithIssueID:(NSString *)theIssueID {
	[super init];
    self.issueId = theIssueID;
	return self;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
    [issueId release];
    [user release];
    [title release];
    [type release];    
    [body release];
    [state release];
    [repo release];
    [created release];
    [updated release];
	[super dealloc];
}

@end
